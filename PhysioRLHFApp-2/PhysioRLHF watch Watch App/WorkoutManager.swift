//
//  WorkoutManager.swift
//  PhysioRLHFApp-2
//
//  Created by Ruifang Zhang on 8/15/25.
//

import Foundation
import HealthKit
import WatchConnectivity
import Combine
import WatchKit

/// Watch side manager: starts/stops HR streaming and pushes BPM to iPhone
final class WorkoutManager: NSObject, ObservableObject {
    static let shared = WorkoutManager()

    @Published var bpm: Int = 0
    @Published var isBackgroundRunning: Bool = false
    @Published var isScreenAlwaysOn: Bool = false

    private let healthStore = HKHealthStore()
    private var hrQuery: HKAnchoredObjectQuery?
    let session: WCSession? = WCSession.isSupported() ? .default : nil
    
    // Background task management
    private var backgroundTask: WKRefreshBackgroundTask?
    private var backgroundTimer: Timer?
    
    // Workout session for keeping screen on
    private var workoutSession: HKWorkoutSession?
    private var workoutBuilder: HKLiveWorkoutBuilder?

    private override init() {
        super.init()
        if let s = session {
            s.delegate = self
            s.activate()
        }
    }

    // Request HealthKit read permission for heartRate
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        guard let hrType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            completion(false); return
        }
        healthStore.requestAuthorization(toShare: nil, read: [hrType]) { ok, _ in
            completion(ok)
        }
    }

    // MARK: - Control from iPhone or local UI

    func start() {
        startHeartRateStreaming()
        startBackgroundMode()
        keepScreenOn()
    }

    func stop() {
        if let q = hrQuery { healthStore.stop(q) }
        hrQuery = nil
        stopBackgroundMode()
        allowScreenToSleep()
    }
    
    // MARK: - Background Mode Management
    
    private func startBackgroundMode() {
        isBackgroundRunning = true
        print("🔄 Starting background mode for heart rate monitoring")
        
        // Schedule background refresh more frequently for real-time data
        WKExtension.shared().scheduleBackgroundRefresh(
            withPreferredDate: Date().addingTimeInterval(5), // Every 5 seconds for near real-time
            userInfo: nil
        ) { error in
            if let error = error {
                print("❌ Failed to schedule background refresh: \(error.localizedDescription)")
            } else {
                print("✅ Background refresh scheduled successfully")
            }
        }
        
        // Also try to send data immediately when new heart rate is available
        // This will work if the watch app is still in background but reachable
        startBackgroundDataTimer()
    }
    
    private func stopBackgroundMode() {
        isBackgroundRunning = false
        print("⏹️ Stopping background mode")
        
        // Cancel background refresh
        WKExtension.shared().scheduleBackgroundRefresh(
            withPreferredDate: Date.distantFuture,
            userInfo: nil
        ) { _ in }
        
        backgroundTimer?.invalidate()
        backgroundTimer = nil
    }
    
    // Called by WKExtensionDelegate when background refresh is triggered
    func handleBackgroundRefresh(_ task: WKRefreshBackgroundTask) {
        print("🔄 Background refresh triggered")
        
        // Continue heart rate monitoring in background
        if isBackgroundRunning {
            // Send current heart rate to iPhone using application context
            if let s = session, let currentBPM = getCurrentHeartRate() {
                do {
                    try s.updateApplicationContext(["bpm": currentBPM])
                    print("📱 Sent heart rate to iPhone in background: \(currentBPM) bpm")
                } catch {
                    print("❌ Failed to send heart rate in background: \(error.localizedDescription)")
                }
            }
        }
        
        // Schedule next background refresh more frequently for real-time data
        WKExtension.shared().scheduleBackgroundRefresh(
            withPreferredDate: Date().addingTimeInterval(5), // Every 5 seconds for near real-time
            userInfo: nil
        ) { _ in }
        
        task.setTaskCompletedWithSnapshot(false)
    }
    
    private func getCurrentHeartRate() -> Int? {
        // Return the last known heart rate value
        return bpm > 0 ? bpm : nil
    }
    
    private func startBackgroundDataTimer() {
        // Send data every 2 seconds when in background mode
        backgroundTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            guard let self = self, self.isBackgroundRunning else { return }
            
            if let s = self.session, let currentBPM = self.getCurrentHeartRate() {
                // Try sendMessage first (works if still reachable)
                if s.isReachable {
                    s.sendMessage(["bpm": currentBPM], replyHandler: nil) { error in
                        print("❌ Background sendMessage failed: \(error.localizedDescription)")
                        // Fallback to application context
                        do {
                            try s.updateApplicationContext(["bpm": currentBPM])
                            print("📱 Background fallback: sent heart rate via application context: \(currentBPM) bpm")
                        } catch {
                            print("❌ Background fallback also failed: \(error.localizedDescription)")
                        }
                    }
                    print("📱 Background: sent heart rate via sendMessage: \(currentBPM) bpm")
                } else {
                    // Use application context if not reachable
                    do {
                        try s.updateApplicationContext(["bpm": currentBPM])
                        print("📱 Background: sent heart rate via application context: \(currentBPM) bpm")
                    } catch {
                        print("❌ Background application context failed: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    // MARK: - Screen Control
    
    private func keepScreenOn() {
        isScreenAlwaysOn = true
        print("💡 Keeping screen always on")
        
        // Method 1: Use haptic feedback to keep screen active
        WKInterfaceDevice.current().play(.notification)
        
        // Method 2: Schedule periodic wake-ups to prevent screen from sleeping
        Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] _ in
            guard let self = self, self.isScreenAlwaysOn else { return }
            
            // Trigger a small haptic feedback to keep the screen awake
            WKInterfaceDevice.current().play(.click)
            print("💡 Screen wake-up triggered")
        }
        
        // Method 3: Use WKExtension to extend background time
        WKExtension.shared().scheduleBackgroundRefresh(
            withPreferredDate: Date().addingTimeInterval(5),
            userInfo: nil
        ) { _ in }
        
        // Method 4: Start a workout session to keep screen on (if HealthKit is available)
        startWorkoutSession()
    }
    
    private func startWorkoutSession() {
        // Create a workout configuration to keep the screen on
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .other
        configuration.locationType = .indoor
        
        do {
            let session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            let builder = session.associatedWorkoutBuilder()
            
            self.workoutSession = session
            self.workoutBuilder = builder
            
            // Start the workout session to keep screen on
            session.startActivity(with: Date())
            builder.beginCollection(withStart: Date()) { success, error in
                if success {
                    print("💡 Workout session started to keep screen on")
                } else if let error = error {
                    print("❌ Failed to start workout session: \(error.localizedDescription)")
                }
            }
        } catch {
            print("❌ Failed to create workout session: \(error.localizedDescription)")
        }
    }
    
    private func allowScreenToSleep() {
        isScreenAlwaysOn = false
        print("😴 Allowing screen to sleep")
        
        // Stop workout session
        if let workoutSession = workoutSession {
            workoutSession.end()
            print("💡 Workout session ended")
        }
        
        if let workoutBuilder = workoutBuilder {
            workoutBuilder.endCollection(withEnd: Date()) { success, error in
                if success {
                    print("💡 Workout builder ended successfully")
                } else if let error = error {
                    print("❌ Failed to end workout builder: \(error.localizedDescription)")
                }
            }
        }
        
        workoutSession = nil
        workoutBuilder = nil
    }

    // MARK: - Heart rate streaming

    private func startHeartRateStreaming() {
        guard let hrType = HKObjectType.quantityType(forIdentifier: .heartRate) else { return }

        let pred = HKQuery.predicateForSamples(withStart: Date(), end: nil, options: .strictStartDate)
        let query = HKAnchoredObjectQuery(type: hrType, predicate: pred, anchor: nil, limit: HKObjectQueryNoLimit) { [weak self] _, samples, _, _, _ in
            self?.handle(samples: samples)
        }
        query.updateHandler = { [weak self] _, samples, _, _, _ in
            self?.handle(samples: samples)
        }
        healthStore.execute(query)
        hrQuery = query
    }

    private func handle(samples: [HKSample]?) {
        guard let qs = samples as? [HKQuantitySample], let last = qs.last else { return }
        let unit = HKUnit.count().unitDivided(by: .minute())
        let value = Int(last.quantity.doubleValue(for: unit))

        DispatchQueue.main.async { self.bpm = value }

        // Push to iPhone - use sendMessage for faster real-time updates when possible
        if let s = session {
            if s.isReachable {
                // Foreground or background but reachable: use sendMessage for real-time updates
                s.sendMessage(["bpm": value], replyHandler: nil) { error in
                    print("❌ sendMessage failed: \(error.localizedDescription)")
                    // Fallback to application context
                    do {
                        try s.updateApplicationContext(["bpm": value])
                        print("📱 Sent heart rate via application context: \(value) bpm")
                    } catch {
                        print("❌ Both sendMessage and updateApplicationContext failed")
                    }
                }
                print("📱 Sent heart rate via sendMessage: \(value) bpm")
            } else {
                // Background and not reachable: use application context
                do {
                    try s.updateApplicationContext(["bpm": value])
                    print("📱 Sent heart rate via application context: \(value) bpm")
                } catch {
                    print("❌ Failed to send heart rate: \(error.localizedDescription)")
                }
            }
        }
    }
}

// MARK: - WCSessionDelegate
extension WorkoutManager: WCSessionDelegate {
    func session(_ session: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?) {
        print("⌚ Watch WCSession activation completed - State: \(activationState.rawValue)")
        if let error = error { 
            print("❌ Watch WC activation error:", error.localizedDescription) 
        } else {
            print("✅ Watch WCSession activated successfully")
        }
        
        DispatchQueue.main.async {
            print("⌚ Watch connection status - Activated: \(activationState == .activated)")
        }
    }

    // Receive commands from iPhone
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let cmd = message["cmd"] as? String {
            switch cmd {
            case "start": start()
            case "stop":  stop()
            case "ping":
                if session.isReachable { session.sendMessage(["pong": 1], replyHandler: nil, errorHandler: nil) }
            case "keepScreenOn": keepScreenOn()
            case "allowScreenSleep": allowScreenToSleep()
            default: break
            }
        }
    }
}

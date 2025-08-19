//
//  WatchHRBridge.swift
//  PhysioRLHFApp-2
//
//  Created by Ruifang Zhang on 8/15/25.
//

// WatchHRBridge.swift (iOS target)
import Foundation
import WatchConnectivity
import Combine

/// iPhone Bridge: Send commands to watch; Receive BPM data from watch
final class WatchHRBridge: NSObject, ObservableObject {
    static let shared = WatchHRBridge()

    // Latest BPM (pushed by watch)
    @Published var lastBPM: Int?
    
    // Heart rate data history
    @Published var heartRateHistory: [HeartRateDataPoint] = []

    // Foreground direct connection (only true when iOS & Watch are in foreground)
    @Published var isReachable: Bool = false

    // ✅ Whether "paired and Watch App installed", this is the basis for your UI to show "Connected"
    @Published var isPairedAndInstalled: Bool = false
    
    // Silent mode - prevent UI updates during task execution
    var silentMode: Bool = false
    
    // Non-published properties for silent data collection
    private var silentLastBPM: Int?
    private var silentHeartRateHistory: [HeartRateDataPoint] = []

    private let session: WCSession? = WCSession.isSupported() ? .default : nil

    private override init() {
        super.init()
        if let s = session {
            s.delegate = self
            s.activate()
                                    // Initial sync once
            #if os(iOS)
            isPairedAndInstalled = s.isPaired && s.isWatchAppInstalled
            #endif
            isReachable = s.isReachable
        } else {
            print("WCSession not supported on this device.")
        }
    }

    // MARK: - Public API for your UI to call

    func startWorkoutOnWatch() { send(["cmd": "start"]) }
    func stopWorkoutOnWatch()  { send(["cmd": "stop"]) }
    func ping()                { send(["cmd": "ping"]) }

    /// Compatible with your previous call name
    func sendPingToWatch() { ping() }

    func activateIfNeeded() { session?.activate() }
    
    // Test function: simulate heart rate data
    func simulateHeartRateData() {
        let simulatedBPM = Int.random(in: 60...100)
        print("🧪 Simulating heart rate data: \(simulatedBPM) bpm")
        
        DispatchQueue.main.async {
            if self.silentMode {
                self.silentLastBPM = simulatedBPM
                let newDataPoint = HeartRateDataPoint(timestamp: Date(), heartRate: simulatedBPM)
                self.silentHeartRateHistory.append(newDataPoint)
                
                if self.silentHeartRateHistory.count > 100 {
                    self.silentHeartRateHistory.removeFirst()
                }
                print("📊 Simulated heart rate collected silently: \(simulatedBPM) bpm")
            } else {
                self.lastBPM = simulatedBPM
                
                // Add to history
                let newDataPoint = HeartRateDataPoint(timestamp: Date(), heartRate: simulatedBPM)
                self.heartRateHistory.append(newDataPoint)
                
                // Keep at most 100 data points
                if self.heartRateHistory.count > 100 {
                    self.heartRateHistory.removeFirst()
                }
                
                print("📊 Simulated heart rate history updated: \(self.heartRateHistory.count) points")
            }
        }
    }
    
    // MARK: - Silent Mode Control
    func enableSilentMode() {
        silentMode = true
        print("🔇 Silent mode enabled - UI updates paused")
    }
    
    func disableSilentMode() {
        silentMode = false
        
        // Sync silent data to published properties
        if let silentBPM = silentLastBPM {
            lastBPM = silentBPM
        }
        
        // Merge silent history with published history
        if !silentHeartRateHistory.isEmpty {
            heartRateHistory.append(contentsOf: silentHeartRateHistory)
            silentHeartRateHistory.removeAll()
            
            // Keep at most 100 data points
            if heartRateHistory.count > 100 {
                let excess = heartRateHistory.count - 100
                heartRateHistory.removeFirst(excess)
            }
        }
        
        print("🔊 Silent mode disabled - \(heartRateHistory.count) data points synced")
    }

    private func send(_ message: [String: Any]) {
        guard let s = session else { return }

        #if os(iOS)
        guard s.isPaired, s.isWatchAppInstalled else {
            print("Watch not paired or app not installed.")
            return
        }
        #endif

        if s.isReachable {
            s.sendMessage(message, replyHandler: nil) { error in
                print("sendMessage error:", error.localizedDescription)
            }
        } else {
            do { try s.updateApplicationContext(message) }
            catch { print("updateApplicationContext error:", error.localizedDescription) }
        }
    }
}

// MARK: - WCSessionDelegate
extension WatchHRBridge: WCSessionDelegate {
    func session(_ session: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?) {
        print("🔗 WCSession activation completed - State: \(activationState.rawValue)")
        if let error = error {
            print("❌ WC activation error:", error.localizedDescription)
        } else {
            print("✅ WCSession activated successfully")
        }

        DispatchQueue.main.async {
            #if os(iOS)
            self.isPairedAndInstalled = session.isPaired && session.isWatchAppInstalled
            #endif
            self.isReachable = session.isReachable
        }
    }

    /// iOS only: Pairing or installation state changes (callback when plugging/unplugging watch, installing/uninstalling Watch App)
    #if os(iOS)
    func sessionWatchStateDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isPairedAndInstalled = session.isPaired && session.isWatchAppInstalled
            print("👀 watch state -> paired:\(session.isPaired) installed:\(session.isWatchAppInstalled)")
        }
    }
    #endif

    /// Foreground direct connection state changes
    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isReachable = session.isReachable
            print("🔄 reachability -> \(session.isReachable)")
        }
    }

    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) { session.activate() }
    #endif

    /// Received message pushed from watch (heart rate, etc.)
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let bpm = message["bpm"] as? Int {
            print("📱 Received heart rate from Watch: \(bpm) bpm")
            
            DispatchQueue.main.async {
                if self.silentMode {
                    // Silent mode: only update private properties, don't trigger UI updates
                    self.silentLastBPM = bpm
                    let newDataPoint = HeartRateDataPoint(timestamp: Date(), heartRate: bpm)
                    self.silentHeartRateHistory.append(newDataPoint)
                    
                    // Keep at most 100 data points
                    if self.silentHeartRateHistory.count > 100 {
                        self.silentHeartRateHistory.removeFirst()
                    }
                    print("📊 Heart rate collected silently: \(bpm) bpm")
                } else {
                    // Normal mode: update published properties
                    self.lastBPM = bpm
                    
                    // Add to history
                    let newDataPoint = HeartRateDataPoint(timestamp: Date(), heartRate: bpm)
                    self.heartRateHistory.append(newDataPoint)
                    
                    // Keep at most 100 data points to avoid excessive memory usage
                    if self.heartRateHistory.count > 100 {
                        self.heartRateHistory.removeFirst()
                    }
                    
                    print("📊 Heart rate history updated: \(self.heartRateHistory.count) points")
                }
            }
        }
        
        // Handle ping reply
        if message["pong"] != nil {
            print("🏓 Received pong from Watch")
        }
    }
}

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

/// Watch side manager: starts/stops HR streaming and pushes BPM to iPhone
final class WorkoutManager: NSObject, ObservableObject {
    static let shared = WorkoutManager()

    @Published var bpm: Int = 0

    private let healthStore = HKHealthStore()
    private var hrQuery: HKAnchoredObjectQuery?
    let session: WCSession? = WCSession.isSupported() ? .default : nil

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
    }

    func stop() {
        if let q = hrQuery { healthStore.stop(q) }
        hrQuery = nil
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

        // Push to iPhone in realtime when reachable
        if let s = session, s.isReachable {
            s.sendMessage(["bpm": value], replyHandler: nil, errorHandler: nil)
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
    }

    // Receive commands from iPhone
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let cmd = message["cmd"] as? String {
            switch cmd {
            case "start": start()
            case "stop":  stop()
            case "ping":
                if session.isReachable { session.sendMessage(["pong": 1], replyHandler: nil, errorHandler: nil) }
            default: break
            }
        }
    }
}

//
//  WatchHRSender.swift
//  PhysioRLHF watch Watch App
//
//  Created by Ruifang Zhang on 8/15/25.
//

import Foundation
import WatchConnectivity

/// Minimal mock sender on watch side. Replace with real HealthKit later.
final class WatchHRSender: NSObject, WCSessionDelegate {
    static let shared = WatchHRSender()

    private let session = WCSession.isSupported() ? WCSession.default : nil
    private var timer: Timer?

    override init() {
        super.init()
        if let s = session {
            s.delegate = self
            s.activate()
        }
    }

    func startMockSending() {
        stop()
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
            let bpm = Int.random(in: 65...85)
            self?.session?.sendMessage(["bpm": bpm], replyHandler: nil, errorHandler: nil)
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }
}

// MARK: - WCSessionDelegate
extension WatchHRSender {
    func session(_ session: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?) {
        // Watch activation completed
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        // Handle messages from iPhone if needed
    }
}

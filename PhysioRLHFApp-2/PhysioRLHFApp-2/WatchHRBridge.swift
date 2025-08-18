//
//  WatchHRBridge.swift
//  PhysioRLHFApp-2
//
//  Created by Ruifang Zhang on 8/15/25.
//

import Foundation
import WatchConnectivity
import Combine

/// iPhone 端桥接：发送命令到手表；接收手表的 BPM 数据
final class WatchHRBridge: NSObject, ObservableObject {
    static let shared = WatchHRBridge()

    @Published var lastBPM: Int?      // 最新 BPM
    @Published var isReachable: Bool = false // ✅ 新增：手表是否可达

    private let session: WCSession? = WCSession.isSupported() ? .default : nil

    private override init() {
        super.init()
        if let s = session {
            s.delegate = self
            s.activate()
            self.isReachable = s.isReachable // 初始化时同步一次状态
        } else {
            print("WCSession not supported on this device.")
        }
    }

    // MARK: - Public API for你的 UI
    func startWorkoutOnWatch() { send(["cmd": "start"]) }
    func stopWorkoutOnWatch()  { send(["cmd": "stop"]) }
    func ping()                { send(["cmd": "ping"]) }
    
#if os(iOS)
/// 检查手表是否已配对且安装了 App
func isPairedAndInstalled() -> Bool {
    guard let s = session else { return false }
    return s.isPaired && s.isWatchAppInstalled
}
#endif

/// 发送 ping 到手表
func sendPingToWatch() {
    send(["cmd": "ping"])
}

    func send(_ message: [String: Any]) {
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
            do {
                try s.updateApplicationContext(message)
            } catch {
                print("updateApplicationContext error:", error.localizedDescription)
            }
        }
    }

    /// 可选：onAppear 时主动激活
    func activateIfNeeded() { session?.activate() }
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
            self.isReachable = session.isReachable
            print("📱 iPhone side - isReachable: \(session.isReachable)")
        }
    }

    // ✅ 关键：监听可达状态变化
    func sessionReachabilityDidChange(_ session: WCSession) {
        print("🔄 Watch reachability changed: \(session.isReachable)")
        DispatchQueue.main.async {
            self.isReachable = session.isReachable
        }
    }

#if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) { session.activate() }
#endif

    // 接收手表发来的 BPM
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let bpm = message["bpm"] as? Int {
            DispatchQueue.main.async { self.lastBPM = bpm }
        }
    }
}

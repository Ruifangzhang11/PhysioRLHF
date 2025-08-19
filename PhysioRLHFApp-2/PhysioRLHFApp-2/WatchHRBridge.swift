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

/// iPhone 端桥接：发送命令到手表；接收手表的 BPM 数据
final class WatchHRBridge: NSObject, ObservableObject {
    static let shared = WatchHRBridge()

    // 最新 BPM（watch 主动推）
    @Published var lastBPM: Int?
    
    // 心率数据历史记录
    @Published var heartRateHistory: [HeartRateDataPoint] = []

    // 前台直连（只有 iOS & Watch 前台时才会 true）
    @Published var isReachable: Bool = false

    // ✅ 是否"已配对且安装了 Watch App"，这是你 UI 要显示"Connected"的依据
    @Published var isPairedAndInstalled: Bool = false

    private let session: WCSession? = WCSession.isSupported() ? .default : nil

    private override init() {
        super.init()
        if let s = session {
            s.delegate = self
            s.activate()
            // 初始化同步一次
            #if os(iOS)
            isPairedAndInstalled = s.isPaired && s.isWatchAppInstalled
            #endif
            isReachable = s.isReachable
        } else {
            print("WCSession not supported on this device.")
        }
    }

    // MARK: - Public API 给你的 UI 调用

    func startWorkoutOnWatch() { send(["cmd": "start"]) }
    func stopWorkoutOnWatch()  { send(["cmd": "stop"]) }
    func ping()                { send(["cmd": "ping"]) }

    /// 兼容你以前调用的名字
    func sendPingToWatch() { ping() }

    func activateIfNeeded() { session?.activate() }
    
    // 测试功能：模拟心率数据
    func simulateHeartRateData() {
        let simulatedBPM = Int.random(in: 60...100)
        print("🧪 Simulating heart rate data: \(simulatedBPM) bpm")
        
        DispatchQueue.main.async {
            self.lastBPM = simulatedBPM
            
            // 添加到历史记录
            let newDataPoint = HeartRateDataPoint(timestamp: Date(), heartRate: simulatedBPM)
            self.heartRateHistory.append(newDataPoint)
            
            // 保持最多100个数据点
            if self.heartRateHistory.count > 100 {
                self.heartRateHistory.removeFirst()
            }
            
            print("📊 Simulated heart rate history updated: \(self.heartRateHistory.count) points")
        }
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

    /// iOS 专用：配对或安装状态变化（插拔表、安装/卸载 Watch App 时会回调）
    #if os(iOS)
    func sessionWatchStateDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isPairedAndInstalled = session.isPaired && session.isWatchAppInstalled
            print("👀 watch state -> paired:\(session.isPaired) installed:\(session.isWatchAppInstalled)")
        }
    }
    #endif

    /// 前台直连状态变化
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

    /// 收到手表推来的消息（心率等）
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let bpm = message["bpm"] as? Int {
            print("📱 Received heart rate from Watch: \(bpm) bpm")
            
            DispatchQueue.main.async {
                self.lastBPM = bpm
                
                // 添加到历史记录
                let newDataPoint = HeartRateDataPoint(timestamp: Date(), heartRate: bpm)
                self.heartRateHistory.append(newDataPoint)
                
                // 保持最多100个数据点，避免内存占用过多
                if self.heartRateHistory.count > 100 {
                    self.heartRateHistory.removeFirst()
                }
                
                print("📊 Heart rate history updated: \(self.heartRateHistory.count) points")
            }
        }
        
        // 处理ping回复
        if message["pong"] != nil {
            print("🏓 Received pong from Watch")
        }
    }
}

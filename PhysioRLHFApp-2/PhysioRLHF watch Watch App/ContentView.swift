//
//  ContentView.swift
//  PhysioRLHF watch Watch App
//
//  Created by Ruifang Zhang on 8/14/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var workoutManager = WorkoutManager.shared
    @State private var isRunning = false

    var body: some View {
        VStack(spacing: 14) {
            // 连接状态
            HStack {
                Image(systemName: workoutManager.session?.isReachable == true ? "iphone" : "iphone.slash")
                    .foregroundColor(workoutManager.session?.isReachable == true ? .green : .red)
                Text(workoutManager.session?.isReachable == true ? "Connected" : "Not Connected")
                    .font(.caption)
                    .foregroundColor(workoutManager.session?.isReachable == true ? .green : .red)
            }
            .padding(.vertical, 4)
            
            // 心率显示
            VStack {
                Text("❤️")
                    .font(.title2)
                Text("\(workoutManager.bpm)")
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                Text("BPM")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)

            // 控制按钮
            HStack(spacing: 14) {
                Button(isRunning ? "Stop" : "Start") {
                    if isRunning {
                        workoutManager.stop()
                    } else {
                        workoutManager.start()
                    }
                    isRunning.toggle()
                }
                .buttonStyle(.borderedProminent)

                Button("Ping") {
                    // 发送ping到iPhone
                    if let session = workoutManager.session, session.isReachable {
                        session.sendMessage(["cmd": "ping"], replyHandler: nil, errorHandler: nil)
                    }
                }
                .buttonStyle(.bordered)
            }
        }
        .onAppear {
            // 请求HealthKit权限
            workoutManager.requestAuthorization { granted in
                print("Watch HealthKit granted:", granted)
            }
        }
    }
}

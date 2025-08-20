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
            // Connection status
            HStack {
                Image(systemName: workoutManager.session?.activationState == .activated ? "iphone" : "iphone.slash")
                    .foregroundColor(workoutManager.session?.activationState == .activated ? .green : .red)
                Text(workoutManager.session?.activationState == .activated ? "Connected" : "Not Connected")
                    .font(.caption)
                    .foregroundColor(workoutManager.session?.activationState == .activated ? .green : .red)
            }
            .padding(.vertical, 4)
            

            
            // Screen always on status
            if workoutManager.isScreenAlwaysOn {
                HStack {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(.yellow)
                    Text("Screen Always On")
                        .font(.caption)
                        .foregroundColor(.yellow)
                }
                .padding(.vertical, 2)
            }
            
            // Heart rate display
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

            // Control buttons
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
                    // Send ping to iPhone
                    if let session = workoutManager.session, session.isReachable {
                        session.sendMessage(["cmd": "ping"], replyHandler: nil, errorHandler: nil)
                    }
                }
                .buttonStyle(.bordered)
            }
        }
        .onAppear {
            // Request HealthKit permission
            workoutManager.requestAuthorization { granted in
                print("Watch HealthKit granted:", granted)
            }
        }
    }
}

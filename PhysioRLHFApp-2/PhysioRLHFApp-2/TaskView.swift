//
//  TaskView.swift
//  PhysioRLHFApp-2
//
//  Created by Ruifang Zhang on 8/8/25.
//

import SwiftUI
import Combine

extension Notification.Name {
    static let taskRoundCompleted = Notification.Name("taskRoundCompleted")
}

// Reuse PairTask from TaskModels.swift
struct TaskView: View {
    @Environment(\.dismiss) private var dismiss

    let title: String
    let tasks: [PairTask]

    @State private var idx: Int = 0
    enum Stage { case readA, readB, decide, done }
    @State private var stage: Stage = .readA
    @State private var secondsLeft: Int = 0

    @State private var startTime: Date?
    @State private var endTime: Date?
    @State private var selected: String?
    @State private var hrStream: [Int] = []
    @State private var optionAHeartRate: [Int] = []
    @State private var optionBHeartRate: [Int] = []
    @State private var currentStageStartTime: Date = Date()
    @State private var timerCancellable: AnyCancellable?
    @State private var hrCancellable: AnyCancellable?

    @State private var isUploading = false
    @State private var uploadStatus: String = ""

    var body: some View {
        let t = tasks[idx]

        VStack(alignment: .leading, spacing: 14) {
            Text(title).font(.title2).bold()
            Text(t.question).font(.headline)

            Group {
                switch stage {
                case .readA:
                    Text("Read A (\(secondsLeft)s)").font(.subheadline).foregroundStyle(.secondary)
                    ScrollView { Text(t.optionA).padding(.top, 6) }
                case .readB:
                    Text("Read B (\(secondsLeft)s)").font(.subheadline).foregroundStyle(.secondary)
                    ScrollView { Text(t.optionB).padding(.top, 6) }
                case .decide, .done:
                    Text("Choose (\(secondsLeft)s)").font(.subheadline).foregroundStyle(.secondary)
                    VStack(spacing: 10) {
                        choiceButton("Option A", isSelected: selected == "A") { selected = "A" }
                        choiceButton("Option B", isSelected: selected == "B") { selected = "B" }
                    }.padding(.top, 6)
                }
            }

            Divider().padding(.vertical, 4)

            HStack {
                Text("❤️ Samples: \(hrStream.count)")
                Spacer()
                Text(stageLabel())
            }
            .font(.footnote).foregroundStyle(.secondary)

            if !uploadStatus.isEmpty {
                Text(uploadStatus)
                    .font(.footnote)
                    .foregroundStyle(uploadStatus.hasPrefix("✅") ? .green : .red)
            }

            Spacer()

            HStack {
                Button("Previous") { prev() }
                    .disabled(idx == 0 || isUploading)

                Spacer()

                Button(idx == tasks.count - 1 ? "Submit Round" : "Next") {
                    if stage == .decide { advanceFromDecideOrSubmit() }
                }
                .buttonStyle(.borderedProminent)
                .disabled(isUploading || stage != .decide || selected == nil)
            }
        }
        .padding()
        .onAppear { startRound() }
        .onDisappear { cleanup() }
        .navigationBarBackButtonHidden(isUploading)
    }

    // MARK: - UI helpers
    @ViewBuilder
    private func choiceButton(_ title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                Spacer()
                if isSelected { Image(systemName: "checkmark.circle.fill").foregroundStyle(.green) }
            }
            .padding()
            .background(Color.gray.opacity(0.12))
            .cornerRadius(12)
        }
    }

    private func stageLabel() -> String {
        switch stage {
        case .readA: return "Stage: Read A"
        case .readB: return "Stage: Read B"
        case .decide: return "Stage: Decide"
        case .done:   return "Stage: Done"
        }
    }

    // MARK: - Flow
    private func startRound() {
        startTime = Date(); endTime = nil; selected = nil; hrStream.removeAll()
        optionAHeartRate.removeAll()
        optionBHeartRate.removeAll()
        currentStageStartTime = Date()
        uploadStatus = ""; isUploading = false
        startHR()
        enter(.readA, seconds: tasks[idx].secReadA)
    }

    private func enter(_ s: Stage, seconds: Int) {
        // Collect data from previous stage before switching
        if stage == .readA && s == .readB {
            // Option A completed, collect the data
            optionAHeartRate = hrStream
            print("📊 Option A completed: collected \(optionAHeartRate.count) heart rate samples")
            // Clear hrStream for option B
            hrStream.removeAll()
        } else if stage == .readB && s == .decide {
            // Option B completed, collect the data
            optionBHeartRate = hrStream
            print("📊 Option B completed: collected \(optionBHeartRate.count) heart rate samples")
            // Clear hrStream for decide stage
            hrStream.removeAll()
        }
        
        stage = s
        secondsLeft = seconds
        currentStageStartTime = Date()
        timerCancellable?.cancel()
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                if secondsLeft > 0 {
                    secondsLeft -= 1
                } else {
                    timerCancellable?.cancel()
                    switch stage {
                    case .readA: enter(.readB, seconds: tasks[idx].secReadB)
                    case .readB: enter(.decide, seconds: tasks[idx].secDecide)
                    case .decide: advanceFromDecideOrSubmit()
                    case .done: break
                    }
                }
            }
    }

    private func advanceFromDecideOrSubmit() {
        guard selected != nil else { return }
        if idx < tasks.count - 1 {
            idx += 1
            startRound()
        } else {
            finishAndUpload()
        }
    }

    private func prev() {
        guard idx > 0 else { return }
        idx -= 1
        startRound()
    }

    // MARK: - 🔄 HR source selection
    private func startHR() {
        // Enable silent mode to prevent UI navigation resets during task
        WatchHRBridge.shared.enableSilentMode()
        
        // Try watch first
        if WatchHRBridge.shared.isWatchConnected {
            print("📱 Using Watch for heart rate data")
            // Subscribe to bridge bpm
            hrCancellable = WatchHRBridge.shared.$lastBPM
                .compactMap { $0 }
                .receive(on: DispatchQueue.main)
                .sink { bpm in
                    hrStream.append(bpm)
                    print("📊 Received BPM from watch: \(bpm)")
                }
            // Wake up watch to start sending
            WatchHRBridge.shared.sendPingToWatch()
        } else {
            print("📱 Using HREmulator for heart rate data")
            // Fallback to simulated heart rate if no watch
            hrCancellable = HREmulator.shared.stream
                .receive(on: DispatchQueue.main)
                .sink { hr in 
                    hrStream.append(hr)
                    print("📊 Received BPM from emulator: \(hr)")
                }
            HREmulator.shared.start()
        }
        
        // Also start a timer to periodically check for silent mode data
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            let silentData = WatchHRBridge.shared.getSilentHeartRateHistory()
            if !silentData.isEmpty {
                // Only add new data points that we haven't seen before
                let currentCount = self.hrStream.count
                if silentData.count > currentCount {
                    let newData = Array(silentData.suffix(silentData.count - currentCount))
                    self.hrStream.append(contentsOf: newData)
                    print("📊 Added \(newData.count) new heart rate samples from silent mode: \(newData)")
                }
            }
        }
    }
    private func cleanup() {
        timerCancellable?.cancel(); timerCancellable = nil
        hrCancellable?.cancel(); hrCancellable = nil

        // Disable silent mode and sync collected data
        WatchHRBridge.shared.disableSilentMode()
        
        // Get the collected heart rate data from the bridge
        let bridgeData = WatchHRBridge.shared.heartRateHistory
        let silentData = WatchHRBridge.shared.getSilentHeartRateHistory()
        
        // Always try to get the most complete data
        if !silentData.isEmpty {
            hrStream = silentData
            print("📊 Retrieved \(hrStream.count) heart rate samples from silent mode history")
        } else if !bridgeData.isEmpty {
            hrStream = bridgeData.map { $0.heartRate }
            print("📊 Retrieved \(hrStream.count) heart rate samples from normal bridge history")
        } else if hrStream.isEmpty {
            print("⚠️ No heart rate data found in bridge history")
        } else {
            print("📊 Using existing hrStream with \(hrStream.count) samples")
        }

        // No need to manually stop Watch (watch is controlled by user clicking Stop); just stop the simulation source here
        HREmulator.shared.stop()
    }

    // MARK: - Upload + notify Home
    private func finishAndUpload() {
        endTime = Date()
        cleanup()
        
        // Use the collected option-specific data
        let optionASamples = optionAHeartRate.isEmpty ? [75,77,79,80,78,82] : optionAHeartRate
        let optionBSamples = optionBHeartRate.isEmpty ? [75,77,79,80,78,82] : optionBHeartRate
        
        print("📊 Option A: \(optionASamples.count) samples, Option B: \(optionBSamples.count) samples")
        
        let reward = simpleReward(from: optionASamples + optionBSamples)

        let t = tasks[idx]
        let record = PhysioRecord(
            user_id: AppIdentity.userID,
            task_id: "cat:\(title)#\(idx)",
            prompt: "[EN] \(t.question)",
            choice: selected == "A" ? "A" : "B",
            start_time: (startTime ?? .now).iso8601String,
            end_time: (endTime ?? .now).iso8601String,
            hr_samples: optionASamples + optionBSamples, // Combined for backward compatibility
            reward: reward,
            meta: [
                "app_version":"0.4",
                "stages":"A(\(t.secReadA))|B(\(t.secReadB))|D(\(t.secDecide))",
                "lang":"en-US",
                "category": title,
                "option_a_hr": optionASamples.map(String.init).joined(separator: ","),
                "option_b_hr": optionBSamples.map(String.init).joined(separator: ","),
                "question": t.question,
                "option_a_content": t.optionA,
                "option_b_content": t.optionB,
                "user_choice": selected == "A" ? "A" : "B",
                "choice_details": selected == "A" ? "User chose Option A" : "User chose Option B"
            ]
        )

        print("📤 Uploading record to Supabase: \(record.task_id)")
        isUploading = true
        Task {
            do {
                try await SupabaseClient.shared.upload(record)
                uploadStatus = "✅ Uploaded to Supabase"
                isUploading = false
                print("✅ Successfully uploaded to Supabase")

                NotificationCenter.default.post(name: .taskRoundCompleted, object: nil, userInfo: [
                    "category": title, "reward": reward
                ])
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { dismiss() }
            } catch {
                uploadStatus = "❌ Upload failed: \(error.localizedDescription)"
                isUploading = false
                print("❌ Upload failed: \(error)")
            }
        }
    }

    private func simpleReward(from hr: [Int]) -> Double {
        guard let maxv = hr.max(), let minv = hr.min(), !hr.isEmpty else { return 0 }
        let fluct = Double(maxv - minv)
        return max(0, 1.0 - min(fluct / 20.0, 1.0))
    }
}

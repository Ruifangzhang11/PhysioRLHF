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
        uploadStatus = ""; isUploading = false
        startHR()
        enter(.readA, seconds: tasks[idx].secReadA)
    }

    private func enter(_ s: Stage, seconds: Int) {
        stage = s
        secondsLeft = seconds
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
        // 先尝试手表
        if WatchHRBridge.shared.isPairedAndInstalled {
            // 订阅桥接的 bpm
            hrCancellable = WatchHRBridge.shared.$lastBPM
                .compactMap { $0 }
                .receive(on: DispatchQueue.main)
                .sink { bpm in
                    hrStream.append(bpm)
                }
            // 唤醒表开始发送
            WatchHRBridge.shared.sendPingToWatch()
        } else {
            // 没有表则回退到模拟心率
            hrCancellable = HREmulator.shared.stream
                .receive(on: DispatchQueue.main)
                .sink { hr in hrStream.append(hr) }
            HREmulator.shared.start()
        }
    }
    private func cleanup() {
        timerCancellable?.cancel(); timerCancellable = nil
        hrCancellable?.cancel(); hrCancellable = nil

        // 无需手动停 Watch（手表由用户点 Stop 控制）；这里停模拟源即可
        HREmulator.shared.stop()
    }

    // MARK: - Upload + notify Home
    private func finishAndUpload() {
        endTime = Date()
        cleanup()
        var samples = hrStream
        if samples.isEmpty { samples = [75,77,79,80,78,82] }
        let reward = simpleReward(from: samples)

        let t = tasks[idx]
        let record = PhysioRecord(
            user_id: AppIdentity.userID,
            task_id: "cat:\(title)#\(idx)",
            prompt: "[EN] \(t.question)",
            choice: selected == "A" ? "A" : "B",
            start_time: (startTime ?? .now).iso8601String,
            end_time: (endTime ?? .now).iso8601String,
            hr_samples: samples,
            reward: reward,
            meta: [
                "app_version":"0.4",
                "stages":"A(\(t.secReadA))|B(\(t.secReadB))|D(\(t.secDecide))",
                "lang":"en-US",
                "category": title
            ]
        )

        isUploading = true
        Task {
            do {
                try await SupabaseClient.shared.upload(record)
                uploadStatus = "✅ Uploaded to Supabase"
                isUploading = false

                NotificationCenter.default.post(name: .taskRoundCompleted, object: nil, userInfo: [
                    "category": title, "reward": reward
                ])
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { dismiss() }
            } catch {
                uploadStatus = "❌ Upload failed: \(error.localizedDescription)"
                isUploading = false
            }
        }
    }

    private func simpleReward(from hr: [Int]) -> Double {
        guard let maxv = hr.max(), let minv = hr.min(), !hr.isEmpty else { return 0 }
        let fluct = Double(maxv - minv)
        return max(0, 1.0 - min(fluct / 20.0, 1.0))
    }
}

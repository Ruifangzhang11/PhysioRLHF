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
    
    // Card animation states
    @State private var cardRotation: Double = 0
    @State private var isFlipping = false
    @State private var showNextCard = false

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.purple.opacity(0.03),
                    Color.blue.opacity(0.02),
                    Color.indigo.opacity(0.03)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 12) {
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(.secondary)
                        }
                        .disabled(isUploading)
                        
                        Spacer()
                        
                        Text(title)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.purple, .blue],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        Spacer()
                        
                        // Progress indicator
                        HStack(spacing: 4) {
                            ForEach(0..<tasks.count, id: \.self) { i in
                                Circle()
                                    .fill(i == idx ? Color.blue : Color.gray.opacity(0.3))
                                    .frame(width: 8, height: 8)
                                    .scaleEffect(i == idx ? 1.2 : 1.0)
                                    .animation(.easeInOut(duration: 0.3), value: idx)
                            }
                        }
                    }
                    
                    // Timer and stage indicator
                    HStack {
                        Text(stageLabel())
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        // Timer
                        HStack(spacing: 6) {
                            Image(systemName: "timer")
                                .font(.caption)
                            Text("\(secondsLeft)s")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(secondsLeft <= 5 ? .red : .primary)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
                
                // Main card content
                ZStack {
                    if !showNextCard {
                        TaskCard(
                            task: tasks[idx],
                            stage: stage,
                            selected: selected,
                            onSelect: { choice in
                                selected = choice
                            }
                        )
                        .rotation3DEffect(
                            .degrees(cardRotation),
                            axis: (x: 0, y: 1, z: 0)
                        )
                        .animation(.easeInOut(duration: 0.6), value: cardRotation)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Bottom info
                VStack(spacing: 12) {
                    // Heart rate info
                    HStack {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                        Text("\(hrStream.count) samples")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        if !uploadStatus.isEmpty {
                            Text(uploadStatus)
                                .font(.caption)
                                .foregroundColor(uploadStatus.hasPrefix("✅") ? .green : .red)
                        }
                    }
                    
                    // Navigation buttons
                    HStack(spacing: 16) {
                        Button(action: prev) {
                            HStack(spacing: 6) {
                                Image(systemName: "chevron.left")
                                Text("Previous")
                            }
                            .font(.subheadline)
                            .foregroundColor(.primary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(.ultraThinMaterial)
                            .cornerRadius(12)
                        }
                        .disabled(idx == 0 || isUploading)
                        
                        Spacer()
                        
                        if stage == .decide {
                            Button(action: advanceFromDecideOrSubmit) {
                                HStack(spacing: 6) {
                                    Text(idx == tasks.count - 1 ? "Submit" : "Next")
                                    Image(systemName: "chevron.right")
                                }
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(
                                    LinearGradient(
                                        colors: selected != nil ? [.blue, .purple] : [.gray],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(12)
                            }
                            .disabled(isUploading || selected == nil)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .onAppear { startRound() }
        .onDisappear { cleanup() }
        .navigationBarHidden(true)
    }

    // MARK: - UI helpers
    private func stageLabel() -> String {
        switch stage {
        case .readA: return "📖 Reading Option A"
        case .readB: return "📖 Reading Option B"
        case .decide: return "🤔 Make Your Choice"
        case .done:   return "✅ Complete"
        }
    }

    // MARK: - Flow
    private func startRound() {
        startTime = Date(); endTime = nil; selected = nil; hrStream.removeAll()
        optionAHeartRate.removeAll()
        optionBHeartRate.removeAll()
        currentStageStartTime = Date()
        uploadStatus = ""; isUploading = false
        showNextCard = false
        cardRotation = 0
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
            // Animate card flip
            withAnimation(.easeInOut(duration: 0.3)) {
                cardRotation = 90
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                idx += 1
                cardRotation = -90
                
                withAnimation(.easeInOut(duration: 0.3)) {
                    cardRotation = 0
                }
                
                startRound()
            }
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
                }
        } else {
            print("📱 Using HREmulator for heart rate data")
            // Fallback to emulator
            hrCancellable = HREmulator.shared.stream
                .receive(on: DispatchQueue.main)
                .sink { bpm in
                    hrStream.append(bpm)
                }
            HREmulator.shared.start()
        }
    }

    private func cleanup() {
        hrCancellable?.cancel()
        timerCancellable?.cancel()
        WatchHRBridge.shared.disableSilentMode()
        HREmulator.shared.stop()
    }

    private func finishAndUpload() {
        endTime = Date()
        isUploading = true
        uploadStatus = "📤 Uploading data..."
        
        // Get heart rate data
        var finalHeartRateData: [Int] = []
        
        // Prioritize silent mode data if available
        let silentData = WatchHRBridge.shared.getSilentHeartRateHistory()
        if !silentData.isEmpty {
            finalHeartRateData = silentData
            print("📊 Retrieved \(silentData.count) heart rate samples from silent mode history")
        } else if !hrStream.isEmpty {
            finalHeartRateData = hrStream
            print("📊 Using \(hrStream.count) heart rate samples from current stream")
        } else {
            finalHeartRateData = WatchHRBridge.shared.heartRateHistory.map { $0.heartRate }
            print("📊 Using \(WatchHRBridge.shared.heartRateHistory.count) heart rate samples from bridge history")
        }
        
        // Remove last 10 seconds from Option B if it has enough data
        if optionBHeartRate.count > 10 {
            optionBHeartRate = Array(optionBHeartRate.dropLast(10))
            print("📊 Removed last 10 seconds from Option B heart rate data")
        }
        
        let t = tasks[idx]
        let record = PhysioRecord(
            user_id: AppIdentity.userID,
            task_id: "\(title)_\(idx)_\(Date().timeIntervalSince1970)",
            prompt: "[EN] \(t.question)",
            choice: selected ?? "unknown",
            start_time: ISO8601DateFormatter().string(from: startTime ?? Date()),
            end_time: ISO8601DateFormatter().string(from: endTime ?? Date()),
            hr_samples: finalHeartRateData,
            reward: Double.random(in: 0.3...1.0),
            meta: [
                "app_version":"0.4",
                "stages":"A(\(t.secReadA))|B(\(t.secReadB))|D(\(t.secDecide))",
                "lang":"en-US",
                "category": title,
                "option_a_hr": optionAHeartRate.map(String.init).joined(separator: ","),
                "option_b_hr": optionBHeartRate.map(String.init).joined(separator: ","),
                "question": t.question,
                "option_a_content": t.optionA,
                "option_b_content": t.optionB,
                "user_choice": selected == "A" ? "A" : "B",
                "choice_details": selected == "A" ? "User chose Option A" : "User chose Option B"
            ]
        )
        
        print("📤 Uploading record to Supabase with \(finalHeartRateData.count) heart rate samples")
        print("📊 Option A: \(optionAHeartRate.count) samples, Option B: \(optionBHeartRate.count) samples")
        
        Task {
            do {
                try await SupabaseClient.shared.upload(record)
                await MainActor.run {
                    uploadStatus = "✅ Upload successful!"
                    let reward = record.reward
                    NotificationCenter.default.post(name: .taskRoundCompleted, object: nil, userInfo: [
                        "category": title, "reward": reward, "taskId": record.task_id
                    ])
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { dismiss() }
                }
            } catch {
                await MainActor.run {
                    uploadStatus = "❌ Upload failed: \(error.localizedDescription)"
                    isUploading = false
                }
            }
        }
    }
}

// MARK: - Task Card Component
struct TaskCard: View {
    let task: PairTask
    let stage: TaskView.Stage
    let selected: String?
    let onSelect: (String) -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Question
            VStack(spacing: 12) {
                Text("Question")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(.ultraThinMaterial)
                    .cornerRadius(8)
                
                Text(task.question)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            // Content based on stage
            Group {
                switch stage {
                case .readA:
                    VStack(spacing: 16) {
                        Text("Option A")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                        
                        ScrollView {
                            Text(task.optionA)
                                .font(.body)
                                .lineSpacing(4)
                                .padding()
                        }
                        .frame(maxHeight: 300)
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(16)
                    
                case .readB:
                    VStack(spacing: 16) {
                        Text("Option B")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.green)
                        
                        ScrollView {
                            Text(task.optionB)
                                .font(.body)
                                .lineSpacing(4)
                                .padding()
                        }
                        .frame(maxHeight: 300)
                    }
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(16)
                    
                case .decide, .done:
                    VStack(spacing: 16) {
                        Text("Choose Your Preference")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        VStack(spacing: 12) {
                            ChoiceCard(
                                title: "Option A",
                                content: task.optionA,
                                isSelected: selected == "A",
                                color: .blue
                            ) {
                                onSelect("A")
                            }
                            
                            ChoiceCard(
                                title: "Option B",
                                content: task.optionB,
                                isSelected: selected == "B",
                                color: .green
                            ) {
                                onSelect("B")
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 10)
        .padding(.horizontal)
    }
}

// MARK: - Choice Card Component
struct ChoiceCard: View {
    let title: String
    let content: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(color)
                    
                    Spacer()
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(color)
                    }
                }
                
                Text(content)
                    .font(.body)
                    .lineLimit(4)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.primary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? color.opacity(0.2) : Color.gray.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? color : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

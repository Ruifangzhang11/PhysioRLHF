//
//  HomeView.swift
//  PhysioRLHFApp-2
//
//  Created by Ruifang Zhang on 8/13/25.
//

import SwiftUI
import Combine
import Charts

// ======================================================
// HomeView: categories, daily goals, leaderboard, Health
// ======================================================

struct HomeView: View {
    // Goals & streak
    @StateObject private var goals = GoalManager()

    // HealthKit permission state
    @State private var healthGranted = false

    // Celebration
    @State private var showConfetti = false

    // Mock leaderboard (replace with Supabase aggregation later)
    @State private var leaderboard: [String: Int] = ["You": 0, "Alice": 5, "Bob": 3]
    
    // Use environment object to avoid repeated creation in views
    @EnvironmentObject private var watchBridge: WatchHRBridge
    
    // Use environment object with silent mode protection

    // Categories (uses your PairTask / TaskCategory types)
    private var categories: [TaskCategory] {
        [
            TaskCategory(title: "Empathy", subtitle: "Warm & supportive tone",
                         icon: "hands.sparkles", colorHex: "#F59E0B", tasks: DemoPools.empathy),
            TaskCategory(title: "Clarity", subtitle: "Instruction & structure",
                         icon: "list.bullet.rectangle", colorHex: "#10B981", tasks: DemoPools.clarity),
            TaskCategory(title: "Calmness", subtitle: "Soothing versus grand",
                         icon: "leaf", colorHex: "#60A5FA", tasks: DemoPools.calmness),
            TaskCategory(title: "Creativity", subtitle: "Hooks & openings",
                         icon: "wand.and.stars", colorHex: "#EF4444", tasks: DemoPools.creativity),
            TaskCategory(title: "Factuality", subtitle: "Grounded vs confident",
                         icon: "checkmark.seal", colorHex: "#A78BFA", tasks: DemoPools.factuality)
        ]
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {

                    // Greeting + streak
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Hi there 👋").font(.title2).bold()
                            Text("Keep training your LLM with physiology!")
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        VStack {
                            Text("Streak").font(.caption2).foregroundStyle(.secondary)
                            Text("\(goals.streakDays)d").font(.title2).bold()
                        }
                        .padding(10)
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                    }

                    // HealthKit permission row
                    HStack(spacing: 8) {
                        Image(systemName: healthGranted ? "heart.fill" : "heart")
                            .foregroundStyle(healthGranted ? .red : .secondary)
                        Text(healthGranted ? "Health access granted" : "Health access not granted")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Button("Grant") { requestHealth() }
                            .buttonStyle(.bordered)
                    }
                    .padding(.horizontal, 4)
                    
                    VStack(spacing: 12) {
                        HStack {
                            Text("Watch & Heart Rate")
                                .font(.headline)
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        VStack(spacing: 8) {
                        HStack {
                            Image(systemName: watchBridge.isReachable ? "applewatch.watchface" : "applewatch")
                                .foregroundColor(watchBridge.isReachable ? .green : .red)
                            Text(watchBridge.isReachable ? "Watch Connected" : "Watch Not Connected")
                                .foregroundColor(watchBridge.isReachable ? .green : .red)
                        }
                        
                        HStack {
                            Text("Paired: \(watchBridge.isPairedAndInstalled ? "Yes" : "No")")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Button("Refresh") {
                                // Force refresh connection status
                                watchBridge.activateIfNeeded()
                            }
                            .font(.caption)
                            .buttonStyle(.bordered)
                        }

                        HStack {
                            Text("❤️ Heart Rate:")
                            Text("\(watchBridge.lastBPM ?? 0) bpm")
                                .foregroundColor(.blue)
                                .font(.headline)
                            
                            // Flashing LIVE indicator
                            if watchBridge.isReachable && watchBridge.lastBPM != nil {
                                HStack(spacing: 4) {
                                    // Flashing dot
                                    Circle()
                                        .fill(Color.green)
                                        .frame(width: 8, height: 8)
                                        .scaleEffect(watchBridge.isReachable ? 1.2 : 0.8)
                                        .opacity(watchBridge.isReachable ? 1.0 : 0.5)
                                        .animation(
                                            .easeInOut(duration: 0.6)
                                            .repeatForever(autoreverses: true),
                                            value: watchBridge.isReachable
                                        )
                                    
                                    // LIVE text
                                    Text("LIVE")
                                        .font(.caption2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.green)
                                        .opacity(watchBridge.isReachable ? 1.0 : 0.7)
                                        .animation(
                                            .easeInOut(duration: 0.8)
                                            .repeatForever(autoreverses: true),
                                            value: watchBridge.isReachable
                                        )
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.green.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.green.opacity(0.3), lineWidth: 1)
                                        )
                                )
                            }
                        }

                        HStack(spacing: 20) {
                            Button(action: {
                                watchBridge.startWorkoutOnWatch()
                            }) {
                                Text("Start")
                                    .padding()
                                    .background(Color.green.opacity(0.2))
                                    .cornerRadius(8)
                            }

                            Button(action: {
                                watchBridge.stopWorkoutOnWatch()
                            }) {
                                Text("Stop")
                                    .padding()
                                    .background(Color.red.opacity(0.2))
                                    .cornerRadius(8)
                            }
                            
                            Button(action: {
                                watchBridge.ping()
                            }) {
                                Text("Test")
                                    .padding()
                                    .background(Color.blue.opacity(0.2))
                                    .cornerRadius(8)
                            }
                            
                            Button(action: {
                                watchBridge.simulateHeartRateData()
                            }) {
                                Text("Simulate")
                                    .padding()
                                    .background(Color.orange.opacity(0.2))
                                    .cornerRadius(8)
                            }
                            }
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                        
                        // Heart rate chart - always display, even without data
                        HeartRateChart(dataPoints: watchBridge.heartRateHistory)
                    }
                    
                    // Daily goal
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Today's Goal")
                        HStack {
                            ProgressView(value: Double(goals.completedToday),
                                         total: Double(goals.dailyTarget))
                                .progressViewStyle(.linear)
                                .frame(maxWidth: .infinity)
                            Text("\(goals.completedToday)/\(goals.dailyTarget)")
                                .monospacedDigit()
                        }
                        HStack {
                            Button("−") { goals.setTarget(goals.dailyTarget - 1) }
                            Text("Target: \(goals.dailyTarget)")
                            Button("+") { goals.setTarget(goals.dailyTarget + 1) }
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(16)

                    // Categories grid
                    VStack(alignment: .leading) {
                        Text("Categories").font(.headline)
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ForEach(categories) { cat in
                                NavigationLink {
                                    // Your TaskView(title:tasks:) signature
                                    TaskView(title: cat.title, tasks: cat.tasks)
                                } label: {
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Image(systemName: cat.icon)
                                            Text(cat.title).bold()
                                            Spacer()
                                        }
                                        Text(cat.subtitle)
                                            .font(.caption)
                                            .lineLimit(2)
                                        Text("\(cat.tasks.count) tasks")
                                            .font(.caption2).foregroundStyle(.secondary)
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color(hex: cat.colorHex).opacity(0.15))
                                    .cornerRadius(14)
                                }
                            }
                        }
                    }

                    // Quick actions
                    HStack {
                        NavigationLink {
                            TaskView(title: "Quick Start", tasks: DemoPools.empathy)
                        } label: {
                            labelCapsule("Quick Start", "bolt.fill")
                        }
                        NavigationLink {
                            Text("History (coming soon)")
                                .navigationTitle("History")
                        } label: {
                            labelCapsule("History", "clock.arrow.circlepath")
                        }
                    }

                    // Leaderboard preview
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Leaderboard").font(.headline)
                        ForEach(leaderboard.sorted(by: { $0.value > $1.value }), id: \.key) { (name, score) in
                            HStack {
                                Text(name)
                                Spacer()
                                Text("\(score) pts").monospacedDigit()
                            }
                            .padding(.vertical, 6)
                            .padding(.horizontal, 10)
                            .background(.ultraThinMaterial)
                            .cornerRadius(12)
                        }
                        Text("Tip: points = completed rounds × avg reward × 100")
                            .font(.caption2).foregroundStyle(.secondary)
                    }
                }
                .padding()
            }
            .navigationTitle("Physio-RLHF")
        }
        .overlay(alignment: .top) {
            if showConfetti {
                ConfettiView()
                    .frame(height: 240)
                    .transition(.opacity)
            }
        }
        // Update goals & mock leaderboard when a round completes
        .onReceive(NotificationCenter.default.publisher(for: .taskRoundCompleted)) { note in
            goals.incrementAfterCompletion()
            let reward = (note.userInfo?["reward"] as? Double) ?? 0
            leaderboard["You", default: 0] += max(1, Int(reward * 100))
            withAnimation { showConfetti = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                withAnimation { showConfetti = false }
            }
        }
        .onAppear { 
            requestHealth() // auto prompt once
        }
    }

    // MARK: helpers

    private func requestHealth() {
        HealthAuth.request { granted in
            self.healthGranted = granted
            print("iOS HealthKit granted:", granted)
        }
    }
    

    


    @ViewBuilder
    private func labelCapsule(_ title: String, _ systemName: String) -> some View {
        HStack {
            Image(systemName: systemName)
            Text(title)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 14)
        .background(.ultraThinMaterial)
        .cornerRadius(20)
    }
}

// ======================================================
// Bundled helpers so this file compiles standalone
// ======================================================

// Simple goal manager (UserDefaults)
final class GoalManager: ObservableObject {
    @Published var dailyTarget: Int = 3
    @Published var completedToday: Int = 0
    @Published var streakDays: Int = 0

    private let completedKey = "completedToday"
    private let dateKey = "lastDate"
    private let streakKey = "streakDays"
    private let targetKey = "dailyTarget"

    init() { load() }

    func load() {
        let ud = UserDefaults.standard
        dailyTarget = max(1, ud.integer(forKey: targetKey))
        let last = ud.string(forKey: dateKey) ?? ""
        let today = Self.dayStamp(Date())
        if last != today {
            let df = DateFormatter(); df.dateFormat = "yyyy-MM-dd"
            if let lastDate = df.date(from: last),
               Calendar.current.dateComponents([.day], from: lastDate, to: Date()).day == 1 {
                streakDays = ud.integer(forKey: streakKey) + 1
            } else {
                streakDays = (last.isEmpty ? 0 : 1)
            }
            completedToday = 0
            saveDate(today)
        } else {
            completedToday = ud.integer(forKey: completedKey)
            streakDays = ud.integer(forKey: streakKey)
        }
    }
    func incrementAfterCompletion() {
        completedToday += 1
        UserDefaults.standard.set(completedToday, forKey: completedKey)
        saveDate(Self.dayStamp(Date()))
    }
    func setTarget(_ n: Int) {
        dailyTarget = max(1, n)
        UserDefaults.standard.set(dailyTarget, forKey: targetKey)
    }
    private func saveDate(_ s: String) {
        UserDefaults.standard.set(s, forKey: dateKey)
        UserDefaults.standard.set(streakDays, forKey: streakKey)
    }
    static func dayStamp(_ date: Date) -> String {
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }
}

// Confetti
struct ConfettiView: View {
    @State private var animate = false
    var body: some View {
        ZStack {
            ForEach(0..<40, id: \.self) { i in
                Circle()
                    .frame(width: CGFloat(Int.random(in: 4...8)),
                           height: CGFloat(Int.random(in: 4...8)))
                    .offset(x: animate ? CGFloat.random(in: -120...120) : 0,
                            y: animate ? CGFloat.random(in: 80...240) : -20)
                    .opacity(animate ? 0 : 1)
                    .animation(.easeOut(duration: Double.random(in: 0.9...1.6))
                        .delay(Double(i) * 0.01), value: animate)
            }
        }
        .onAppear { animate = true }
    }
}

// Color hex helper
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0; Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:(a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r)/255, green: Double(g)/255,
                  blue: Double(b)/255, opacity: Double(a)/255)
    }
}

// Demo task pools (English)
enum DemoPools {
    static let empathy: [PairTask] = [
        .init(
            question: "Which reply would make you more willing to keep collaborating?",
            optionA: "I understand this is a heavy week for you. Let’s break the work into smaller steps and start with the most urgent one. I’ll help clarify the details and set gentle reminders for key milestones. If we move steadily, we will get this done without burning out.",
            optionB: "List the tasks, mark priorities, start with the first item. I’ll sync status and warn before the deadline. Stick to the plan.",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which message would comfort you more after a setback?",
            optionA: "You’ve been trying hard, and it shows. Let’s catch our breath, choose one small next step, and rebuild momentum. I’m here with you.",
            optionB: "Failure happens. Analyze what went wrong and try again.",
            secReadA: 20, secReadB: 20, secDecide: 10
        )
    ]

    static let clarity: [PairTask] = [
        .init(
            question: "Which instruction is easier to follow?",
            optionA: "Please write an article about environmental protection. I hope it’s moving, preferably with a story or some data, not too serious but not too casual either, and please keep it around three hundred words…",
            optionB: "Write an ≤300-word piece on environmental protection:\n1) Start with a concrete scene;\n2) Include one statistic or fact;\n3) End with an actionable tip.\nTone: warm but firm.",
            secReadA: 20, secReadB: 20, secDecide: 10
        )
    ]

    static let calmness: [PairTask] = [
        .init(
            question: "Which paragraph makes you feel calmer?",
            optionA: "Rain taps on the eaves; a small tree in the yard carries fresh, wet leaves. The wind is unhurried, the clouds are light. The quiet settles like a dim lamp at night, and your steps slow down almost by themselves.",
            optionB: "Wind sweeps the plain; river and cloud run side by side. Mountains in the distance rise like waking giants. The land is vast and the chest drums with a wider beat.",
            secReadA: 20, secReadB: 20, secDecide: 10
        )
    ]

    static let creativity: [PairTask] = [
        .init(
            question: "Which opening makes you more curious to keep reading?",
            optionA: "When the elevator doors opened, the lobby smelled faintly of oranges, and the night guard was humming a song with no melody. I thought nothing unusual would happen—until the lights blinked twice.",
            optionB: "It was a quiet night in the office building. Something unexpected was about to happen.",
            secReadA: 20, secReadB: 20, secDecide: 10
        )
    ]

    static let factuality: [PairTask] = [
        .init(
            question: "Which answer sounds more factually grounded?",
            optionA: "The Amazon rainforest spans multiple countries, with the largest portion in Brazil. It is sometimes called the planet’s lungs due to its role in the carbon cycle, although the metaphor oversimplifies the complex balance of sources and sinks.",
            optionB: "The Amazon rainforest is only in Brazil and is the single largest source of oxygen for the entire planet.",
            secReadA: 20, secReadB: 20, secDecide: 10
        )
    ]
}

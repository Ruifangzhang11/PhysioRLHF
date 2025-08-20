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

struct GlassGradientButtonStyle: ButtonStyle {
    let isActive: Bool
    let gradientColors: [Color]
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: isActive ? gradientColors : gradientColors.map { $0.opacity(0.3) }),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.white.opacity(0.3), Color.clear]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: isActive ? (gradientColors.first?.opacity(0.3) ?? Color.clear) : Color.clear, radius: 8, x: 0, y: 4)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
            .animation(.easeInOut(duration: 0.3), value: isActive)
    }
}

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
            ZStack {
                // 高级渐变背景
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.blue.opacity(0.1),
                        Color.purple.opacity(0.05),
                        Color.pink.opacity(0.1)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
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
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
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
                                    Image(systemName: watchBridge.isWatchConnected ? "applewatch.watchface" : "applewatch")
                                        .foregroundColor(watchBridge.isWatchConnected ? .green : .red)
                                    Text(watchBridge.isWatchConnected ? "Watch Connected" : "Watch Not Connected")
                                        .foregroundColor(watchBridge.isWatchConnected ? .green : .red)
                                }
                                
                                HStack {
                                    Text("Connected: \(watchBridge.isWatchConnected ? "Yes" : "No")")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Button("Refresh") {
                                        watchBridge.activateIfNeeded()
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                            if let wcSession = watchBridge.session {
                                                #if os(iOS)
                                                watchBridge.isWatchConnected = wcSession.isPaired && wcSession.isWatchAppInstalled && wcSession.isReachable
                                                #endif
                                                watchBridge.isReachable = wcSession.isReachable
                                            }
                                        }
                                    }
                                    .font(.caption)
                                    .buttonStyle(.bordered)
                                }
                                
                                // Flashing LIVE indicator
                                if watchBridge.isWatchConnected && watchBridge.lastBPM != nil {
                                    HStack {
                                        Circle()
                                            .fill(Color.green)
                                            .frame(width: 8, height: 8)
                                            .scaleEffect(1.0)
                                            .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: watchBridge.lastBPM)
                                        Text("LIVE")
                                            .font(.caption)
                                            .foregroundColor(.green)
                                        Spacer()
                                    }
                                }
                                
                                // Heart rate display
                                if let bpm = watchBridge.lastBPM {
                                    HStack {
                                        Text("❤️ \(bpm) BPM")
                                            .font(.title2)
                                            .bold()
                                        Spacer()
                                    }
                                } else {
                                    HStack {
                                        Text("No heart rate data")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Spacer()
                                    }
                                }
                                
                                // Control buttons
                                HStack(spacing: 20) {
                                    Button(action: {
                                        watchBridge.startWorkoutOnWatch()
                                    }) {
                                        HStack(spacing: 4) {
                                            Image(systemName: "play.fill")
                                                .font(.caption)
                                            Text("Start")
                                                .font(.caption)
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .foregroundColor(watchBridge.isWorkoutActive ? .white : .primary)
                                    }
                                    .buttonStyle(GlassGradientButtonStyle(
                                        isActive: watchBridge.isWorkoutActive,
                                        gradientColors: [Color.green, Color.green.opacity(0.7)]
                                    ))
                                    .disabled(watchBridge.isWorkoutActive)

                                    Button(action: {
                                        watchBridge.stopWorkoutOnWatch()
                                    }) {
                                        HStack(spacing: 4) {
                                            Image(systemName: "stop.fill")
                                                .font(.caption)
                                            Text("Stop")
                                                .font(.caption)
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .foregroundColor(watchBridge.isWorkoutActive ? .white : .primary)
                                    }
                                    .buttonStyle(GlassGradientButtonStyle(
                                        isActive: watchBridge.isWorkoutActive,
                                        gradientColors: [Color.red, Color.red.opacity(0.7)]
                                    ))
                                    .disabled(!watchBridge.isWorkoutActive)
                                    
                                    Button(action: {
                                        watchBridge.ping()
                                    }) {
                                        HStack(spacing: 4) {
                                            Image(systemName: "heart.fill")
                                                .font(.caption)
                                            Text("Test")
                                                .font(.caption)
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .foregroundColor(.primary)
                                    }
                                    .buttonStyle(GlassGradientButtonStyle(
                                        isActive: false,
                                        gradientColors: [Color.purple.opacity(0.3), Color.purple.opacity(0.1)]
                                    ))
                                }
                            }
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                        
                        // Heart rate chart - always display, even without data
                        HeartRateChart(dataPoints: watchBridge.heartRateHistory)
                    }
                    
                    // Daily goal
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Today's Goal")
                        HStack {
                            ProgressView(value: Double(max(0, min(goals.completedToday, goals.dailyTarget))),
                                         total: Double(max(1, goals.dailyTarget)))
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
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)

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
                            HistoryView()
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
            optionA: "I understand this is a heavy week for you. Let's break the work into smaller steps and start with the most urgent one. I'll help clarify the details and set gentle reminders for key milestones. If we move steadily, we will get this done without burning out.",
            optionB: "List the tasks, mark priorities, start with the first item. I'll sync status and warn before the deadline. Stick to the plan.",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which message would comfort you more after a setback?",
            optionA: "You've been trying hard, and it shows. Let's catch our breath, choose one small next step, and rebuild momentum. I'm here with you.",
            optionB: "Failure happens. Analyze what went wrong and try again.",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which response would better support someone grieving a loss?",
            optionA: "I can't imagine how painful this must be for you. There are no words that can make this easier, but I want you to know that I'm here. Take all the time you need, and don't feel pressured to 'get over it' or 'move on' for anyone else's sake.",
            optionB: "Time heals all wounds. You'll feel better soon. Try to stay busy and focus on the positive things in your life.",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which approach would help someone struggling with anxiety?",
            optionA: "I can see this is really overwhelming for you right now. Let's take it one moment at a time. What's one small thing that might help you feel a bit more grounded right now? Maybe we could try some deep breathing together, or you could tell me what's most frightening about this situation.",
            optionB: "Anxiety is just in your head. You need to stop overthinking and just relax. Think positive thoughts and everything will be fine.",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which message would better support someone dealing with imposter syndrome?",
            optionA: "I understand that feeling of not belonging, even when you've worked so hard to get here. Your achievements are real, and your presence in this space is valuable. Many people feel this way, even those who seem completely confident. You're not alone in this struggle.",
            optionB: "You just need more confidence. Stop doubting yourself and believe in your abilities. Everyone gets nervous sometimes, but you need to get over it.",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which response would better help someone feeling isolated?",
            optionA: "I hear how lonely you're feeling, and that sounds really hard. Even though I can't be there physically, I want you to know that you matter to me. Would you like to talk about what's been going on? Sometimes just being heard can make a world of difference.",
            optionB: "You should get out more and meet new people. Join some clubs or go to social events. Being alone is a choice, so make different choices.",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which approach would better support someone with depression?",
            optionA: "I can see you're going through something really difficult, and I want you to know that it's okay to not be okay. Depression is a real illness, not a weakness. Have you considered talking to a professional? I'm here to support you in whatever way feels right for you.",
            optionB: "You just need to snap out of it and be more positive. Look at all the good things in your life. Stop being so negative and start appreciating what you have.",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which message would better comfort someone after a breakup?",
            optionA: "I know this hurts so much right now, and that's completely normal. Breakups can feel like a death, and you need time to grieve. Don't rush yourself to feel better. Your feelings are valid, and it's okay to take as much time as you need to heal.",
            optionB: "There are plenty of other fish in the sea. You'll find someone better soon. Don't waste time being sad about someone who didn't appreciate you.",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which response would better help someone dealing with work stress?",
            optionA: "I can see how overwhelmed you're feeling with all these deadlines and expectations. It sounds like you're carrying a lot on your shoulders. What would help you feel more supported right now? Maybe we could brainstorm some ways to prioritize or delegate some of this work.",
            optionB: "Everyone deals with stress at work. You need to toughen up and learn to handle pressure better. Stop complaining and just get the work done.",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which approach would better support someone with body image issues?",
            optionA: "I hear how much you're struggling with how you see yourself, and I want you to know that your worth isn't defined by your appearance. You are so much more than what you look like. Have you considered talking to someone about these feelings? You deserve to feel comfortable in your own skin.",
            optionB: "You just need to lose some weight and exercise more. Once you look better, you'll feel better about yourself. It's all about willpower.",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which message would better help someone dealing with family conflict?",
            optionA: "Family relationships can be so complicated and painful. It's okay to feel hurt and confused when the people who are supposed to love us unconditionally don't. You don't have to have all the answers right now. Sometimes just acknowledging how hard this is can be a first step toward healing.",
            optionB: "Family is family, so you need to forgive and forget. They're your blood, so you should just get over whatever happened and move on.",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which response would better support someone with chronic illness?",
            optionA: "I can only imagine how frustrating and exhausting it must be to deal with this every day. Chronic illness is so much more than just being sick - it affects every aspect of your life. Your experience is valid, and it's okay to feel angry or sad about how this has changed things for you.",
            optionB: "You just need to stay positive and think happy thoughts. Mind over matter - if you believe you can get better, you will. Stop focusing on the negative.",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which approach would better help someone dealing with financial stress?",
            optionA: "I can see how worried you are about money, and that's a really heavy burden to carry. Financial stress affects everything - your sleep, your relationships, your health. You're not alone in this struggle. Would you like to talk about what's most concerning to you right now? Sometimes just having a plan can help reduce the anxiety.",
            optionB: "You just need to budget better and stop spending money on unnecessary things. Everyone has money problems, so stop complaining and figure it out.",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which message would better comfort someone dealing with aging parents?",
            optionA: "I can see how much you're carrying - the worry, the guilt, the exhaustion. Caring for aging parents is one of the hardest things we do, and it's okay to feel overwhelmed. You're doing the best you can in an impossible situation. Don't forget to take care of yourself too - you can't pour from an empty cup.",
            optionB: "It's your responsibility to take care of your parents. They took care of you, so now it's your turn. Stop complaining and just do what needs to be done.",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which response would better help someone dealing with infertility?",
            optionA: "I can only imagine how painful this journey has been for you. The monthly cycle of hope and disappointment, the feeling that your body is betraying you, the way this affects every aspect of your life - it's so much to carry. Your feelings are completely valid, and you don't have to pretend to be okay when you're not.",
            optionB: "You just need to relax and stop stressing about it. Many people get pregnant when they stop trying so hard. Just adopt if you can't have your own children.",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which approach would better support someone dealing with addiction recovery?",
            optionA: "I can see how hard you're working in your recovery, and I want you to know that every day you choose to stay sober is a victory. Recovery isn't linear, and setbacks don't mean you've failed. You're doing something incredibly difficult, and I'm here to support you however I can.",
            optionB: "You just need more willpower. Stop making excuses and take responsibility for your actions. If you really wanted to quit, you would just do it.",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which message would better help someone dealing with discrimination?",
            optionA: "I can only imagine how exhausting and demoralizing it must be to face discrimination day after day. The constant microaggressions, the feeling that you have to work twice as hard to prove yourself, the way it chips away at your sense of self-worth - it's so much to carry. Your experience is real and valid, and you don't have to minimize it for anyone else's comfort.",
            optionB: "You just need to work harder and prove them wrong. Don't let them get to you - just focus on being the best you can be and ignore the haters.",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which response would better support someone dealing with trauma?",
            optionA: "I can see how much pain you're carrying, and I want you to know that your trauma is real and valid. What happened to you wasn't your fault, and you don't have to carry this burden alone. Healing from trauma takes time, and there's no right or wrong way to process what you've been through. You're doing the best you can.",
            optionB: "You need to stop dwelling on the past and move on. What's done is done, and you can't change it. Focus on the present and stop letting it control your life.",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which approach would better help someone dealing with caregiving burnout?",
            optionA: "I can see how exhausted you are, both physically and emotionally. Caregiving is one of the most demanding roles there is, and it's okay to feel overwhelmed. You're doing so much for others, but don't forget that you matter too. It's not selfish to need a break or to ask for help. You can't pour from an empty cup.",
            optionB: "You signed up for this when you agreed to be a caregiver. Stop complaining and just do what needs to be done. Other people have it worse than you.",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which message would better comfort someone dealing with climate anxiety?",
            optionA: "I understand how overwhelming and frightening it can feel to think about the future of our planet. Climate anxiety is a real and valid response to what's happening in our world. It's okay to feel scared and uncertain. You're not alone in these feelings, and it's important to find ways to take care of yourself while still staying engaged with the issues that matter to you.",
            optionB: "You just need to stop watching the news and focus on your own life. There's nothing you can do about climate change anyway, so stop worrying about things you can't control.",
            secReadA: 20, secReadB: 20, secDecide: 10
        )
    ]

    static let clarity: [PairTask] = [
        .init(
            question: "Which instruction is easier to follow?",
            optionA: "Please write an article about environmental protection. I hope it's moving, preferably with a story or some data, not too serious but not too casual either, and please keep it around three hundred words…",
            optionB: "Write an ≤300-word piece on environmental protection:\n1) Start with a concrete scene;\n2) Include one statistic or fact;\n3) End with an actionable tip.\nTone: warm but firm.",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which project brief is clearer?",
            optionA: "We need a website for our company. It should look professional and modern, with good colors and maybe some animations. We want people to be able to contact us and learn about our services. Make it user-friendly and make sure it works on phones too.",
            optionB: "Create a responsive company website with:\n• Homepage: Company overview + hero section\n• Services page: 3 main service categories\n• Contact page: Contact form + map\n• Mobile-first design\n• Professional color scheme (blue/gray)\n• Contact form validation",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which meeting agenda is more structured?",
            optionA: "Let's discuss the project updates, budget concerns, team issues, and plan for next quarter. Also talk about the client feedback and maybe some new ideas. We should also address the technical problems and figure out the timeline.",
            optionB: "Project Review Meeting (60 min):\n1. Project Status (15 min)\n   - Current milestones\n   - Blockers & solutions\n2. Budget Review (10 min)\n   - Current spending vs. allocated\n3. Team Updates (15 min)\n   - Individual progress reports\n4. Q4 Planning (20 min)\n   - Goals & resource allocation",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which recipe is easier to follow?",
            optionA: "Make a chocolate cake. Mix some flour and sugar, add eggs and milk, then chocolate. Bake it until it's done. Don't forget to grease the pan. You can add some vanilla if you want. The temperature should be medium-high.",
            optionB: "Chocolate Cake Recipe:\nIngredients:\n• 2 cups all-purpose flour\n• 1¾ cups sugar\n• ¾ cup cocoa powder\n• 2 eggs\n• 1 cup milk\n• ½ cup vegetable oil\n\nInstructions:\n1. Preheat oven to 350°F (175°C)\n2. Grease 9-inch round pan\n3. Mix dry ingredients in large bowl\n4. Add wet ingredients, mix until smooth\n5. Pour into pan, bake 30-35 minutes",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which job description is more specific?",
            optionA: "We're looking for someone to help with marketing stuff. They should be creative and know about social media. Experience is good but not required. They'll work with the team and help grow our business. Good communication skills are important.",
            optionB: "Marketing Coordinator Position:\nRequirements:\n• 2+ years digital marketing experience\n• Proficiency in Facebook Ads, Google Analytics\n• Experience with email marketing platforms\n• Bachelor's degree in Marketing or related field\n\nResponsibilities:\n• Manage social media accounts (Facebook, Instagram, LinkedIn)\n• Create and optimize paid ad campaigns\n• Analyze campaign performance and report monthly\n• Coordinate with design team for content creation",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which travel itinerary is better organized?",
            optionA: "Go to Paris and see the Eiffel Tower, maybe visit some museums, eat at nice restaurants, and walk around the city. You should also check out the Louvre and Notre Dame. Don't forget to take pictures and try the local food.",
            optionB: "Paris 3-Day Itinerary:\nDay 1: Arrival & Eiffel Tower\n• 2:00 PM: Check into hotel\n• 4:00 PM: Eiffel Tower visit (book tickets in advance)\n• 7:00 PM: Dinner at Le Jules Verne\n\nDay 2: Museums & Culture\n• 9:00 AM: Louvre Museum (3 hours)\n• 2:00 PM: Notre Dame Cathedral\n• 6:00 PM: Seine River cruise\n\nDay 3: Shopping & Departure\n• 10:00 AM: Champs-Élysées shopping\n• 2:00 PM: Arc de Triomphe\n• 6:00 PM: Airport transfer",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which workout plan is clearer?",
            optionA: "Do some cardio, maybe running or cycling, then do some strength training with weights. Work on your core and legs. Don't forget to stretch. Try to exercise a few times a week and gradually increase the intensity.",
            optionB: "3-Day Workout Plan:\nMonday - Cardio & Core:\n• 20 min HIIT intervals\n• 3 sets: 15 crunches, 30 sec plank, 20 Russian twists\n• 10 min cool-down stretch\n\nWednesday - Upper Body:\n• 3 sets: 10 push-ups, 12 dumbbell rows, 8 shoulder presses\n• 15 min moderate cardio\n• 5 min stretch\n\nFriday - Lower Body:\n• 3 sets: 15 squats, 12 lunges, 10 calf raises\n• 20 min steady-state cardio\n• 10 min stretch",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which study guide is more helpful?",
            optionA: "Study for the exam by reading the textbook and reviewing your notes. Focus on the important topics and make sure you understand the main concepts. Practice with some questions and get enough sleep before the test.",
            optionB: "Exam Study Plan (5 days):\nDay 1: Chapters 1-3\n• Read summaries, create flashcards\n• Practice problems 1-20\n• Review key formulas\n\nDay 2: Chapters 4-6\n• Focus on diagrams and charts\n• Complete practice test A\n• Identify weak areas\n\nDay 3: Chapters 7-9\n• Review flashcards from days 1-2\n• Practice problems 21-40\n• Study group session\n\nDay 4: Full Review\n• Complete practice test B\n• Review all flashcards\n• Create summary sheet\n\nDay 5: Final Prep\n• Light review only\n• Early bedtime\n• Prepare materials",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which event planning checklist is more comprehensive?",
            optionA: "Plan the party by getting food and drinks, decorating the venue, inviting people, and making sure everything is ready on time. Don't forget the music and maybe some games or activities. Have a backup plan in case of bad weather.",
            optionB: "Event Planning Checklist:\n6 weeks before:\n• Set budget and date\n• Book venue and vendors\n• Create guest list\n\n4 weeks before:\n• Send invitations\n• Order decorations\n• Plan menu and order catering\n\n2 weeks before:\n• Confirm RSVPs\n• Create timeline\n• Plan backup activities\n\n1 week before:\n• Final vendor confirmations\n• Prepare emergency kit\n• Assign day-of tasks\n\nDay of:\n• Setup checklist\n• Vendor contact list\n• Weather contingency plan",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which troubleshooting guide is more useful?",
            optionA: "If your computer is slow, try restarting it. Sometimes you need to close some programs or check if there are updates. If that doesn't work, maybe you have a virus or need more memory. You could also try cleaning up files.",
            optionB: "Computer Performance Troubleshooting:\nStep 1: Quick Fixes\n• Restart computer\n• Close unnecessary programs\n• Check for Windows updates\n\nStep 2: System Analysis\n• Open Task Manager, check CPU/Memory usage\n• Run disk cleanup\n• Check for malware with Windows Defender\n\nStep 3: Advanced Solutions\n• Uninstall unused programs\n• Add more RAM if usage >80%\n• Consider SSD upgrade if using HDD\n\nStep 4: Professional Help\n• If issues persist, contact IT support\n• Consider system restore or reinstall",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which budget template is more detailed?",
            optionA: "Track your income and expenses. Write down how much money you make and spend each month. Try to save some money and avoid unnecessary purchases. Keep receipts and check your bank statements regularly.",
            optionB: "Monthly Budget Template:\nIncome:\n• Salary: $_______\n• Side income: $_______\n• Other: $_______\nTotal Income: $_______\n\nFixed Expenses:\n• Rent/Mortgage: $_______\n• Utilities: $_______\n• Insurance: $_______\n• Subscriptions: $_______\n\nVariable Expenses:\n• Groceries: $_______\n• Transportation: $_______\n• Entertainment: $_______\n• Shopping: $_______\n\nSavings Goals:\n• Emergency fund: $_______\n• Retirement: $_______\n• Other goals: $_______",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which presentation outline is better structured?",
            optionA: "Start with an introduction about the topic, then present the main points and data. Include some examples and maybe a case study. End with conclusions and recommendations. Use slides with bullet points and some charts.",
            optionB: "Presentation Structure (20 min):\n1. Introduction (3 min)\n   - Hook: Startling statistic\n   - Agenda overview\n   - Why this matters\n\n2. Problem Statement (5 min)\n   - Current situation\n   - Pain points\n   - Impact on business\n\n3. Solution Overview (8 min)\n   - Proposed approach\n   - Key benefits\n   - Implementation timeline\n\n4. Case Study (3 min)\n   - Real example\n   - Results achieved\n\n5. Conclusion (1 min)\n   - Key takeaways\n   - Next steps\n   - Q&A",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which customer service script is more effective?",
            optionA: "When a customer calls with a problem, be polite and try to help them. Listen to what they say and apologize if something went wrong. Offer to fix the issue or give them a refund. Make sure they're satisfied before ending the call.",
            optionB: "Customer Service Call Script:\nGreeting: 'Thank you for calling [Company]. My name is [Name]. How can I help you today?'\n\nActive Listening:\n• Acknowledge the issue\n• Ask clarifying questions\n• Repeat back the problem\n\nProblem Resolution:\n• Offer immediate solution if possible\n• Explain next steps if escalation needed\n• Set clear expectations for follow-up\n\nClosing:\n• Confirm resolution\n• Ask if anything else needed\n• Thank customer for patience\n• Document call details",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which onboarding process is more thorough?",
            optionA: "Show the new employee around the office, introduce them to the team, and explain their job responsibilities. Give them the necessary equipment and access to systems. Answer any questions they have and make them feel welcome.",
            optionB: "Employee Onboarding Checklist:\nWeek 1:\n• Day 1: Office tour, IT setup, team introductions\n• Day 2: System access, email setup, company policies\n• Day 3: Job shadowing, mentor assignment\n• Day 4: Training sessions, project overview\n• Day 5: First assignment, feedback session\n\nWeek 2:\n• Complete required training modules\n• Meet with department heads\n• Begin independent work\n• Weekly check-in with manager\n\nMonth 1:\n• Performance review\n• Goal setting\n• Integration assessment",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which research methodology is clearer?",
            optionA: "Study the topic by reading books and articles, talking to experts, and maybe doing some surveys or interviews. Analyze the data you collect and draw conclusions. Make sure your sources are reliable and your methods are appropriate.",
            optionB: "Research Methodology:\nPhase 1: Literature Review (2 weeks)\n• Identify key databases and sources\n• Review 20+ peer-reviewed articles\n• Create annotated bibliography\n• Identify research gaps\n\nPhase 2: Data Collection (4 weeks)\n• Design survey questionnaire\n• Recruit participants (target: 100)\n• Conduct semi-structured interviews (15 participants)\n• Collect quantitative and qualitative data\n\nPhase 3: Analysis (2 weeks)\n• Statistical analysis of survey data\n• Thematic analysis of interviews\n• Cross-reference findings\n• Validate conclusions",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which project timeline is more realistic?",
            optionA: "Start the project and work on it over the next few weeks. Set some milestones and check in regularly to see how things are going. Adjust the schedule if needed and make sure to finish on time. Keep everyone updated on progress.",
            optionB: "Project Timeline (12 weeks):\nWeeks 1-2: Planning Phase\n• Requirements gathering\n• Stakeholder interviews\n• Project scope definition\n• Resource allocation\n\nWeeks 3-6: Development Phase\n• Sprint 1: Core features (2 weeks)\n• Sprint 2: Advanced features (2 weeks)\n• Weekly progress reviews\n• Risk assessment updates\n\nWeeks 7-9: Testing Phase\n• Unit testing\n• Integration testing\n• User acceptance testing\n• Bug fixes and refinements\n\nWeeks 10-12: Deployment\n• Final testing\n• Documentation completion\n• Training sessions\n• Go-live and monitoring",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which evaluation criteria are more objective?",
            optionA: "Assess the work based on quality, effort, and results. Consider how well they did compared to expectations and whether they met the goals. Take into account their experience level and the difficulty of the task.",
            optionB: "Performance Evaluation Criteria:\nQuality (40%):\n• Accuracy: 0-10 points\n• Completeness: 0-10 points\n• Professional standards: 0-10 points\n• Innovation: 0-10 points\n\nEfficiency (30%):\n• Timeliness: 0-10 points\n• Resource utilization: 0-10 points\n• Process improvement: 0-10 points\n\nCollaboration (20%):\n• Teamwork: 0-10 points\n• Communication: 0-10 points\n\nLeadership (10%):\n• Initiative: 0-5 points\n• Mentoring: 0-5 points\n\nTotal: 100 points possible",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which feedback format is more constructive?",
            optionA: "Tell them what they did well and what they could improve. Be specific about the issues and suggest ways to fix them. Give both positive and negative feedback to help them grow and develop their skills.",
            optionB: "Constructive Feedback Template:\nStrengths (What went well):\n• Specific examples of good work\n• Positive behaviors to continue\n• Impact of their contributions\n\nAreas for Improvement:\n• Specific issues with examples\n• Impact of these issues\n• Concrete suggestions for improvement\n\nAction Plan:\n• Specific steps to take\n• Timeline for improvement\n• Resources or support needed\n• Follow-up schedule\n\nOverall Assessment:\n• Summary of performance\n• Growth potential\n• Next review date",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which decision-making framework is more systematic?",
            optionA: "Think about the pros and cons of each option, consider the risks and benefits, and think about how it will affect different people. Talk to others who might be affected and make sure you have enough information before deciding.",
            optionB: "Decision-Making Framework:\nStep 1: Define the Problem\n• What decision needs to be made?\n• What are the constraints?\n• Who are the stakeholders?\n\nStep 2: Gather Information\n• Research all options\n• Collect relevant data\n• Consult experts\n• Consider past experiences\n\nStep 3: Evaluate Options\n• List pros and cons\n• Assess risks and benefits\n• Consider short and long-term impacts\n• Rate each option (1-10)\n\nStep 4: Make Decision\n• Choose best option\n• Document rationale\n• Plan implementation\n\nStep 5: Review and Learn\n• Monitor outcomes\n• Assess decision quality\n• Apply lessons learned",
            secReadA: 20, secReadB: 20, secDecide: 10
        )
    ]

    static let calmness: [PairTask] = [
        .init(
            question: "Which paragraph makes you feel calmer?",
            optionA: "Rain taps on the eaves; a small tree in the yard carries fresh, wet leaves. The wind is unhurried, the clouds are light. The quiet settles like a dim lamp at night, and your steps slow down almost by themselves.",
            optionB: "Wind sweeps the plain; river and cloud run side by side. Mountains in the distance rise like waking giants. The land is vast and the chest drums with a wider beat.",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which meditation guidance feels more soothing?",
            optionA: "Sit comfortably and close your eyes. Take a deep breath in through your nose, feeling your chest rise gently. Hold for a moment, then exhale slowly through your mouth, letting all tension flow out with your breath. Feel the weight of your body supported by the earth beneath you.",
            optionB: "Close your eyes and focus on your breathing. Inhale deeply and exhale completely. Clear your mind of all thoughts. Concentrate only on your breath. Empty your mind completely. Achieve perfect stillness.",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which nature description feels more peaceful?",
            optionA: "A gentle stream flows over smooth stones, its soft murmur blending with the rustle of leaves overhead. Sunlight filters through the canopy, creating dancing patterns on the forest floor. A butterfly lands briefly on a wildflower, then drifts away on a warm breeze.",
            optionB: "Thunder crashes across the valley as lightning splits the sky. Rain pours down in sheets, turning the path into a rushing torrent. The wind howls through the trees, bending branches and scattering leaves across the storm-tossed landscape.",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which bedtime story opening is more relaxing?",
            optionA: "Once upon a time, in a cottage nestled between rolling hills, lived a gentle baker who made bread that smelled like sunshine. Each morning, she would open her windows to let in the soft light, and the whole village would wake to the warm scent of fresh bread floating on the breeze.",
            optionB: "In a dark castle on a stormy night, a brave knight prepared for battle against a fearsome dragon. The wind howled through the stone corridors as lightning flashed, illuminating ancient weapons hanging on the walls. The knight's heart pounded with anticipation of the coming fight.",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which yoga instruction feels more gentle?",
            optionA: "Begin in a comfortable seated position, feeling the ground supporting you. Let your shoulders relax, your jaw soften, and your breath find its natural rhythm. With each inhale, imagine drawing in peace and calm. With each exhale, release any tension or worry.",
            optionB: "Assume the warrior pose with your legs wide apart. Bend your front knee deeply, reaching your arms high above your head. Hold this challenging position while maintaining steady breathing. Feel the burn in your muscles as you push through the discomfort.",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which garden description feels more tranquil?",
            optionA: "A small herb garden grows beside a weathered stone path, where lavender and rosemary release their gentle fragrance into the afternoon air. Bees hum contentedly among the flowers, and a small fountain bubbles softly in the corner, its water catching the sunlight like liquid silver.",
            optionB: "A vast botanical garden stretches across acres of land, with towering trees and exotic plants from around the world. Tourists crowd the pathways, cameras clicking and voices echoing through the glass conservatory. The air is thick with humidity and the scent of tropical flowers.",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which breathing exercise feels more calming?",
            optionA: "Place one hand on your chest and one on your belly. Breathe in slowly through your nose for a count of four, feeling your belly rise. Hold for a moment, then breathe out gently through your mouth for a count of six, feeling your body relax with each exhale.",
            optionB: "Take rapid, deep breaths in and out through your mouth. Breathe as quickly and deeply as you can, filling your lungs completely and emptying them entirely. Continue this intense breathing pattern for several minutes to energize your body.",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which music description feels more soothing?",
            optionA: "Soft piano notes drift through the room like falling leaves, each melody flowing gently into the next. The music seems to breathe with you, rising and falling like gentle waves on a quiet shore. Time seems to slow down as the harmonies wrap around you like a warm blanket.",
            optionB: "Electric guitars scream through amplifiers as drums pound out a relentless rhythm. The bass vibrates through your chest, and the singer's voice rises above the chaos in passionate intensity. The music demands your attention and energy.",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which tea ceremony description feels more peaceful?",
            optionA: "In a quiet room, steam rises gently from a porcelain teapot as leaves unfurl in hot water. The ritual of warming the cups, measuring the tea, and waiting for the perfect steeping time creates a moment of mindfulness. Each sip brings warmth and a sense of connection to tradition.",
            optionB: "A bustling tea house fills with the clatter of cups and animated conversation. Servers rush between tables, pouring tea quickly to keep up with the demand. The air is thick with the aroma of many different teas brewing simultaneously.",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which sunset description feels more serene?",
            optionA: "The sun sinks slowly behind distant hills, painting the sky in soft shades of pink and gold. Long shadows stretch across the meadow as the day's warmth lingers in the air. Birds call softly to each other as they settle in for the night, and a gentle breeze carries the scent of wildflowers.",
            optionB: "The sun disappears in a blaze of orange and red, setting the clouds on fire with brilliant color. The sky seems to burn with intensity as the light fades, creating dramatic silhouettes against the horizon. The temperature drops rapidly as darkness falls.",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which massage description feels more relaxing?",
            optionA: "Gentle hands work slowly across tense muscles, using warm oil and steady pressure to release knots and tension. The touch is firm but never painful, following the natural rhythm of your breathing. Each stroke seems to melt away stress, leaving you feeling lighter and more at peace.",
            optionB: "Strong hands dig deep into tight muscles, applying intense pressure to break up adhesions and release deep tension. The massage is vigorous and sometimes uncomfortable, but effective at targeting problem areas. You can feel the muscles releasing under the firm pressure.",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which forest walk description feels more calming?",
            optionA: "A narrow path winds through ancient trees, their branches creating a natural canopy overhead. Sunlight filters through the leaves in dappled patterns, and the air is cool and fresh. Your footsteps are muffled by a carpet of fallen leaves, and the only sounds are birdsong and the whisper of wind through the branches.",
            optionB: "A wide trail cuts through dense undergrowth, with branches reaching out to grab at your clothing. The path is steep and challenging, requiring careful footing on loose rocks and roots. The air is thick with humidity, and insects buzz loudly around your head.",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which bath description feels more soothing?",
            optionA: "Warm water surrounds you like a gentle embrace, scented with lavender and chamomile. Bubbles float on the surface, catching the soft light from candles placed around the room. The steam rises gently, carrying the calming fragrance, and you can feel the day's tension melting away.",
            optionB: "Hot water fills the tub, creating clouds of steam that fog the mirrors. The temperature is almost too hot to bear, but you force yourself to stay in, feeling the heat penetrate deep into your muscles. The air is thick with humidity and the scent of strong bath salts.",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which morning routine description feels more peaceful?",
            optionA: "You wake naturally as sunlight filters through your curtains, feeling rested and refreshed. You stretch slowly, taking time to greet the new day. A cup of herbal tea steams gently beside you as you sit quietly, watching the world wake up outside your window.",
            optionB: "The alarm blares loudly, jolting you from sleep. You hit snooze twice before forcing yourself out of bed, feeling groggy and rushed. You quickly shower and dress, gulping down coffee as you check your phone for urgent messages and prepare for a busy day ahead.",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which ocean scene description feels more tranquil?",
            optionA: "Gentle waves lap against the shore in a steady, soothing rhythm. The water is clear and calm, reflecting the sky like a mirror. Seagulls glide overhead, their calls carried on the breeze, and the sand is warm beneath your feet as you walk along the water's edge.",
            optionB: "Powerful waves crash against the rocks, sending spray high into the air. The ocean churns with energy, its surface broken by whitecaps and foam. The wind whips across the water, and the sound of the surf is loud enough to drown out conversation.",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which bedtime ritual description feels more calming?",
            optionA: "You dim the lights and light a few candles, their soft glow creating a warm, intimate atmosphere. You spend a few minutes writing in your journal, reflecting on the day's blessings. Then you read a few pages of a favorite book, letting the familiar words lull you toward sleep.",
            optionB: "You check your phone one last time, scrolling through social media and responding to messages. The bright screen keeps your mind active as you think about tomorrow's tasks and deadlines. You set multiple alarms to ensure you don't oversleep, then try to force yourself to relax.",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which cooking description feels more peaceful?",
            optionA: "You chop vegetables slowly and mindfully, enjoying the rhythm of the knife against the cutting board. The kitchen fills with the warm aroma of herbs and spices as you stir a pot of soup that has been simmering all afternoon. Cooking becomes a meditation, each step bringing you deeper into the present moment.",
            optionB: "You rush around the kitchen, trying to prepare multiple dishes simultaneously. Pots boil over, timers beep urgently, and you juggle several tasks at once. The kitchen is hot and chaotic, with ingredients scattered across every surface as you race against the clock.",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which reading environment description feels more relaxing?",
            optionA: "You curl up in a comfortable chair by the window, with a soft blanket draped over your lap. A cup of tea steams gently beside you, and the afternoon light filters through the curtains, creating a warm, golden atmosphere. The house is quiet except for the gentle hum of the refrigerator and the turning of pages.",
            optionB: "You sit at a crowded coffee shop, surrounded by the buzz of conversation and the hiss of the espresso machine. People come and go, creating a constant flow of movement and noise. You try to focus on your book while the barista calls out orders and music plays overhead.",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which pet interaction description feels more soothing?",
            optionA: "Your cat purrs contentedly in your lap, its warm weight and steady breathing creating a sense of peace. You stroke its soft fur gently, feeling the vibration of its purr against your hand. The cat's eyes close in contentment as it settles deeper into your lap, completely relaxed and trusting.",
            optionB: "Your dog bounds around the room excitedly, knocking over objects and barking loudly. It jumps up on you repeatedly, demanding attention and play. The energy is high and chaotic as the dog races from one end of the room to the other, unable to settle down.",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which art activity description feels more calming?",
            optionA: "You dip your brush into watercolors, watching the colors flow and blend on the paper. There's no pressure to create something perfect - you simply enjoy the process of mixing colors and watching them spread. Each brushstroke is deliberate and mindful, bringing you into a state of focused relaxation.",
            optionB: "You work frantically on a deadline-driven project, trying to complete a complex piece in time for a client meeting. Your hands move quickly across the canvas, making rapid decisions about composition and color. The pressure to produce something impressive creates tension in your shoulders and neck.",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which weather description feels more peaceful?",
            optionA: "A gentle mist hangs in the air, softening the edges of everything it touches. The world seems quieter, as if wrapped in cotton. Droplets of water gather on leaves and spider webs, catching the light like tiny diamonds. The air is cool and fresh, carrying the scent of damp earth.",
            optionB: "A storm approaches, with dark clouds gathering on the horizon. Lightning flashes in the distance, followed by the deep rumble of thunder. The wind picks up, bending trees and sending leaves swirling through the air. The pressure drops, creating an atmosphere of anticipation and tension.",
            secReadA: 20, secReadB: 20, secDecide: 10
        )
    ]

    static let creativity: [PairTask] = [
        .init(
            question: "Which opening makes you more curious to keep reading?",
            optionA: "When the elevator doors opened, the lobby smelled faintly of oranges, and the night guard was humming a song with no melody. I thought nothing unusual would happen—until the lights blinked twice.",
            optionB: "It was a quiet night in the office building. Something unexpected was about to happen.",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which story premise is more intriguing?",
            optionA: "A librarian discovers that every book returned after midnight contains handwritten notes from the future, predicting events that haven't happened yet. The notes become increasingly urgent, warning of a catastrophe only she can prevent.",
            optionB: "A detective investigates a murder case in a small town. The evidence points to several suspects, and he must figure out who committed the crime.",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which character introduction is more compelling?",
            optionA: "Dr. Elena Vasquez had performed over 200 surgeries, but none had prepared her for the moment when her patient's heart stopped beating—and then started again, with a rhythm that matched the Morse code message she'd received that morning.",
            optionB: "John Smith was a successful businessman who lived in a nice house with his wife and two children. He worked hard and enjoyed spending time with his family on weekends.",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which plot twist is more surprising?",
            optionA: "The detective finally catches the serial killer, only to discover that the killer is actually a time traveler from the future, trying to prevent a catastrophic event by eliminating people who will cause it.",
            optionB: "The detective discovers that the killer was the victim's business partner, who wanted to take over the company.",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which world-building detail is more imaginative?",
            optionA: "In this world, emotions are visible as colored auras around people's heads. Red for anger, blue for sadness, green for envy. But the protagonist sees a color no one has ever seen before—a shifting rainbow that changes with every thought.",
            optionB: "The story takes place in a futuristic city where people use advanced technology for transportation and communication. The buildings are tall and made of glass and steel.",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which dialogue opening is more engaging?",
            optionA: "'I'm sorry, but I can't marry you,' she said, holding up her hand to show him the ring that had just turned black. 'It seems the universe has other plans.'",
            optionB: "'Hello, how are you today?' she asked politely as they sat down for coffee.",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which mystery setup is more intriguing?",
            optionA: "Every morning, a different person wakes up with complete amnesia in the town square. They remember nothing about their past, but they all have the same tattoo on their wrist: coordinates that lead to an abandoned lighthouse.",
            optionB: "A valuable painting is stolen from a museum. The police investigate and find clues that lead them to suspect an inside job.",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which fantasy element is more original?",
            optionA: "In this world, people can trade memories like currency. The rich hoard beautiful memories of perfect moments, while the poor sell their precious memories to survive. But memories can be counterfeit, and some people are born without the ability to form new ones.",
            optionB: "There are magical creatures like dragons and elves living in a forest. The protagonist discovers they have magical powers and must learn to use them.",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which conflict setup is more compelling?",
            optionA: "A scientist discovers a way to communicate with plants, only to learn that the entire natural world is planning a coordinated attack against humanity for centuries of environmental destruction. She must choose between warning humanity or joining the plants' cause.",
            optionB: "Two companies are competing for the same business contract. The protagonist must decide which company to work for and help them win the contract.",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which character motivation is more complex?",
            optionA: "A woman seeks revenge against the man who killed her family, but discovers that he's actually her future self, who traveled back in time to prevent a greater tragedy that will occur if she doesn't act. She must decide whether to kill herself to save others.",
            optionB: "A man wants to get a promotion at work so he can earn more money and provide a better life for his family.",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which setting description is more atmospheric?",
            optionA: "The old mansion stood at the edge of the cliff, its windows reflecting the storm clouds like dark mirrors. Inside, the air smelled of dust and secrets, and the floorboards creaked with the weight of forgotten memories. In the library, books whispered to each other in languages no human could understand.",
            optionB: "The house was large and old, with many rooms and a big garden. It had been in the family for generations and contained many antiques and family heirlooms.",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which supernatural element is more unique?",
            optionA: "People can see the exact moment of their death reflected in any mirror, but only when they're not looking directly at it. The protagonist discovers that their reflection shows them dying tomorrow, but when they try to look directly at it, the image changes to show them dying next week.",
            optionB: "There are ghosts that haunt the old house. They can move objects and make strange noises, and some people can see and communicate with them.",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which relationship dynamic is more interesting?",
            optionA: "A woman falls in love with a man who exists only in her dreams. Every night, they meet in a shared dream world, but she can't find him in real life. When she finally does, she discovers he's been in a coma for years, and their dream relationship is the only thing keeping him alive.",
            optionB: "Two people meet at work and gradually fall in love. They face some challenges in their relationship but eventually get married and live happily ever after.",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which technological concept is more innovative?",
            optionA: "Scientists develop a device that can extract and store human emotions in crystal form. These emotion crystals can be traded, experienced by others, or used to power machines. But the process leaves the original person emotionless, creating a black market for stolen feelings.",
            optionB: "A new smartphone is released with advanced features like facial recognition and voice commands. It becomes very popular and changes how people communicate.",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which moral dilemma is more thought-provoking?",
            optionA: "A doctor discovers a way to transfer consciousness between bodies. A dying billionaire offers to pay for the doctor's daughter's life-saving treatment in exchange for transferring the billionaire's mind into the daughter's healthy body. The doctor must choose between saving their child and committing murder.",
            optionB: "A person finds a wallet with money in it. They must decide whether to return it to the owner or keep the money for themselves.",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which historical reimagining is more creative?",
            optionA: "In an alternate 1940s, the Nazis discovered how to weaponize human emotions, turning fear into physical weapons and joy into energy sources. The resistance fights back using a secret network of artists who can paint emotions into reality, creating hope where there is none.",
            optionB: "The story takes place during World War II. A spy infiltrates enemy territory to gather information and help the Allied forces win the war.",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which psychological element is more intriguing?",
            optionA: "A woman begins to experience the memories of a stranger as if they were her own. At first, they're just fragments—a childhood birthday party, a first kiss, a car accident. But as the memories become more vivid, she realizes they're not random: they're all from people who are about to die, and she's the only one who can save them.",
            optionB: "A person has nightmares about being chased. They go to therapy to understand why they're having these dreams and learn to cope with their anxiety.",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which adventure premise is more exciting?",
            optionA: "A group of explorers discovers a cave system where each chamber contains a different moment in time. They can walk through history, but each visit ages them rapidly, and they must choose which moments to witness before they become too old to return home.",
            optionB: "A group of friends goes on a hiking trip in the mountains. They get lost and must find their way back to civilization while surviving in the wilderness.",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which social commentary is more subtle?",
            optionA: "In a society where people are ranked by their ability to dream, the protagonist discovers that the government is secretly harvesting dreams to power their surveillance system. The most creative dreamers are the most valuable, but their dreams are being used to control the population.",
            optionB: "The story shows how social media affects people's lives and relationships. Characters become obsessed with getting likes and followers, which causes problems in their real relationships.",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which ending setup is more satisfying?",
            optionA: "The protagonist finally solves the mystery, only to discover that the solution reveals a truth so profound that it changes the fundamental nature of reality. The story doesn't just end—it transforms into something entirely new, leaving readers questioning everything they thought they knew.",
            optionB: "The protagonist catches the bad guy, justice is served, and everyone lives happily ever after. The story concludes with a wedding and the promise of a bright future.",
            secReadA: 20, secReadB: 20, secDecide: 10
        )
    ]

    static let factuality: [PairTask] = [
        .init(
            question: "Which answer sounds more factually grounded?",
            optionA: "The Amazon rainforest spans multiple countries, with the largest portion in Brazil. It is sometimes called the planet's lungs due to its role in the carbon cycle, although the metaphor oversimplifies the complex balance of sources and sinks.",
            optionB: "The Amazon rainforest is only in Brazil and is the single largest source of oxygen for the entire planet.",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which statement about climate change is more accurate?",
            optionA: "Climate change is a complex phenomenon influenced by multiple factors including greenhouse gas emissions, solar activity, and natural climate cycles. The scientific consensus indicates human activities are the primary driver of recent warming, with global temperatures rising approximately 1.1°C since pre-industrial times.",
            optionB: "Climate change is a hoax created by scientists to get more funding. The Earth's temperature has always fluctuated naturally, and there's no evidence that human activities have any significant impact on the climate.",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which description of vaccines is more scientifically accurate?",
            optionA: "Vaccines work by introducing a weakened or inactivated form of a pathogen to stimulate the immune system to produce antibodies. This creates immunological memory, so the body can respond more effectively if exposed to the actual pathogen later. Most vaccines require multiple doses for optimal protection.",
            optionB: "Vaccines contain dangerous chemicals that weaken your immune system and can cause autism. They're part of a conspiracy to make people sick so pharmaceutical companies can sell more medicine.",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which explanation of evolution is more accurate?",
            optionA: "Evolution is the process by which populations of organisms change over time through natural selection, genetic drift, and other mechanisms. It occurs when heritable traits that confer advantages in survival and reproduction become more common in a population over generations.",
            optionB: "Evolution is just a theory that hasn't been proven. There's no evidence that humans evolved from other animals, and the fossil record shows that all species appeared suddenly and haven't changed since.",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which statement about nutrition is more evidence-based?",
            optionA: "A balanced diet should include a variety of foods from different food groups, with emphasis on whole grains, fruits, vegetables, lean proteins, and healthy fats. Individual nutritional needs vary based on age, activity level, health status, and other factors. There's no single 'perfect' diet for everyone.",
            optionB: "You should only eat organic food because all conventional food is full of dangerous chemicals that will poison you. The only way to be healthy is to follow a strict vegan diet and avoid all processed foods completely.",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which description of mental health is more accurate?",
            optionA: "Mental health conditions are complex disorders influenced by biological, psychological, and social factors. They can affect anyone regardless of age, background, or circumstances. Treatment approaches vary and may include therapy, medication, lifestyle changes, or a combination of these, depending on the individual's needs.",
            optionB: "Mental illness is just a sign of weakness or lack of willpower. People with depression just need to think positive thoughts, and anxiety is all in your head. Taking medication for mental health problems is dangerous and addictive.",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which statement about exercise is more scientifically grounded?",
            optionA: "Regular physical activity provides numerous health benefits including improved cardiovascular health, stronger bones and muscles, better mental health, and reduced risk of chronic diseases. The recommended amount varies by age and fitness level, but generally includes both aerobic and strength training activities.",
            optionB: "You need to exercise for at least 2 hours every day to be healthy. If you're not sweating profusely and feeling completely exhausted, you're not working out hard enough. Only intense workouts count as real exercise.",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which explanation of sleep is more accurate?",
            optionA: "Sleep is essential for physical and mental health, playing crucial roles in memory consolidation, immune function, and cellular repair. Most adults need 7-9 hours per night, though individual needs vary. Sleep quality is as important as quantity, with deep sleep and REM sleep serving different restorative functions.",
            optionB: "Sleep is just a waste of time. Successful people only need 4-5 hours of sleep per night, and you can train your body to function perfectly on less sleep. The more you sleep, the lazier you become.",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which statement about technology is more factual?",
            optionA: "Technology has both positive and negative impacts on society. While it has improved communication, healthcare, and productivity, it also presents challenges like privacy concerns, digital addiction, and job displacement. The effects vary depending on how technology is developed and used.",
            optionB: "Technology is destroying society and making everyone stupid. Social media is brainwashing people, and smartphones are causing cancer. We should go back to living without any modern technology.",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which description of economics is more accurate?",
            optionA: "Economics studies how societies allocate scarce resources to meet unlimited wants and needs. It involves complex interactions between individuals, businesses, and governments, influenced by factors like supply and demand, incentives, market structures, and policy decisions. Economic outcomes are rarely simple or predictable.",
            optionB: "Economics is simple - just print more money to solve poverty, and raise taxes on the rich to pay for everything. The government can control the economy completely and should just give everyone free money.",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which statement about history is more evidence-based?",
            optionA: "Historical events are complex and often have multiple causes and consequences. Our understanding of history evolves as new evidence is discovered and different perspectives are considered. Historical interpretation requires careful analysis of primary sources, context, and multiple viewpoints.",
            optionB: "History is just a series of dates and facts that never change. The history books tell us exactly what happened, and there's no room for different interpretations. Everything in the past was simpler and better than today.",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which explanation of psychology is more accurate?",
            optionA: "Psychology is the scientific study of mind and behavior, encompassing various approaches including cognitive, behavioral, biological, and social perspectives. Human behavior is influenced by multiple factors including genetics, environment, experiences, and current circumstances. Psychological research uses rigorous scientific methods.",
            optionB: "Psychology is just common sense and anyone can be a psychologist. All human behavior can be explained by simple rules, and people who study psychology are just trying to read minds and control people's thoughts.",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which statement about medicine is more scientifically grounded?",
            optionA: "Modern medicine combines scientific research, clinical experience, and patient preferences to provide evidence-based care. Medical treatments are developed through rigorous testing and regulatory approval processes. While medicine has made tremendous advances, there are still many conditions that remain challenging to treat effectively.",
            optionB: "Doctors don't really know anything and just prescribe dangerous drugs with terrible side effects. Natural remedies are always better and safer than any medicine. The pharmaceutical industry is hiding cures for diseases to make more money.",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which description of education is more evidence-based?",
            optionA: "Effective education involves multiple factors including quality teaching, student engagement, appropriate resources, and supportive environments. Learning styles and needs vary among individuals, and successful education systems adapt to these differences. Research shows that both traditional and innovative approaches can be effective when properly implemented.",
            optionB: "Education is simple - just memorize facts and take tests. The traditional classroom model is perfect and doesn't need to change. Technology in education is just a distraction and makes students dumber.",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which statement about social media is more accurate?",
            optionA: "Social media has complex effects on society, offering benefits like increased connectivity and information sharing while also presenting challenges like misinformation, privacy concerns, and potential impacts on mental health. The effects vary significantly depending on how platforms are designed and how individuals use them.",
            optionB: "Social media is completely destroying society and making everyone depressed and addicted. It's only used for spreading fake news and cyberbullying. The only solution is to delete all social media accounts immediately.",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which explanation of genetics is more scientifically accurate?",
            optionA: "Genetics is the study of heredity and variation in living organisms. Genes provide instructions for building and maintaining cells, but their expression is influenced by environmental factors and complex interactions. Most traits result from the interaction of multiple genes and environmental factors, not single genes.",
            optionB: "Genes determine everything about a person - their intelligence, personality, and behavior. If your parents are smart, you'll be smart. If they're athletic, you'll be athletic. There's nothing you can do to change your genetic destiny.",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which statement about renewable energy is more factual?",
            optionA: "Renewable energy sources like solar, wind, and hydroelectric power offer environmental benefits but also face challenges including intermittency, storage limitations, and infrastructure requirements. The transition to renewable energy involves complex technical, economic, and policy considerations that vary by region and circumstance.",
            optionB: "Renewable energy is perfect and will solve all our problems immediately. Solar and wind power are completely free and reliable, and we should replace all fossil fuels right now. Anyone who opposes renewable energy is just greedy and doesn't care about the environment.",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which description of artificial intelligence is more accurate?",
            optionA: "Artificial intelligence encompasses various technologies that can perform tasks typically requiring human intelligence, such as pattern recognition and decision-making. Current AI systems are specialized tools rather than general intelligence, and their capabilities and limitations depend on their training data and design.",
            optionB: "AI is already smarter than humans and will take over the world soon. Robots will replace all human workers and either enslave or destroy humanity. There's nothing we can do to stop this from happening.",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which statement about democracy is more evidence-based?",
            optionA: "Democracy is a complex system of government that requires active citizen participation, independent institutions, and protection of minority rights. Democratic systems vary widely in their effectiveness and face ongoing challenges including polarization, misinformation, and ensuring equal representation. Success depends on multiple factors beyond just holding elections.",
            optionB: "Democracy is simple - just vote and everything will be perfect. The majority is always right, and any problems with democracy are caused by people who don't agree with the majority. Democracy automatically solves all social and economic problems.",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which explanation of poverty is more accurate?",
            optionA: "Poverty is a complex social issue influenced by multiple factors including economic systems, education, healthcare access, discrimination, and historical circumstances. Solutions require comprehensive approaches addressing root causes rather than simple fixes. Poverty affects different groups and regions in varying ways.",
            optionB: "Poverty is just caused by laziness and poor choices. If people would just work harder and make better decisions, they wouldn't be poor. The solution is simple - just give people jobs and they'll automatically become wealthy.",
            secReadA: 20, secReadB: 20, secDecide: 10
        ),
        .init(
            question: "Which statement about crime is more evidence-based?",
            optionA: "Crime is influenced by complex social, economic, and psychological factors including poverty, education, mental health, community resources, and systemic inequalities. Crime rates vary significantly across different communities and time periods, and effective prevention requires addressing underlying causes rather than just punishment.",
            optionB: "Crime is simple - bad people do bad things because they're evil. The only solution is harsher punishment and longer prison sentences. If we lock up all criminals forever, crime will disappear completely.",
            secReadA: 20, secReadB: 20, secDecide: 10
        )
    ]
}

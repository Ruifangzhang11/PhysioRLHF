//
//  HomeView.swift
//  PhysioRLHFApp-2
//
//  Created by Ruifang Zhang on 8/8/25.
//

import SwiftUI

// HomeView: categories, daily goals, Health
struct HomeView: View {
    // Goals & streak
    @StateObject private var goals = GoalManager()

    // HealthKit permission state
    @State private var healthGranted = false

    // Celebration
    @State private var showConfetti = false
    
    @State private var selectedTab = 0
    
    // Use environment object to avoid repeated creation in views
    @EnvironmentObject private var watchBridge: WatchHRBridge
    
    // Auth manager for user info
    @StateObject private var authManager = AuthManager.shared



    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Tab Picker
                Picker("View", selection: $selectedTab) {
                    Text("Home").tag(0)
                    Text("Tasks").tag(1)
                    Text("Profile").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Tab Content
                TabView(selection: $selectedTab) {
                    // Home Tab
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
                                        if authManager.isAuthenticated, let user = authManager.currentUser {
                                            Text("Welcome back, \(user.username) 🚀")
                                                .font(.title2)
                                                .fontWeight(.bold)
                                                .foregroundStyle(
                                                    LinearGradient(
                                                        colors: [
                                                            Color.purple.opacity(0.9),
                                                            Color.blue.opacity(0.8),
                                                            Color.cyan.opacity(0.7)
                                                        ],
                                                        startPoint: .leading,
                                                        endPoint: .trailing
                                                    )
                                                )
                                        } else {
                                            Text("Ready to train? 🧠")
                                                .font(.title2)
                                                .fontWeight(.bold)
                                                .foregroundStyle(
                                                    LinearGradient(
                                                        colors: [
                                                            Color.orange.opacity(0.9),
                                                            Color.pink.opacity(0.8),
                                                            Color.purple.opacity(0.7)
                                                        ],
                                                        startPoint: .leading,
                                                        endPoint: .trailing
                                                    )
                                                )
                                        }
                                        if authManager.isAuthenticated, let user = authManager.currentUser {
                                            Text("Continue your AI training journey with \(user.completedTasks) tasks completed! 🎯")
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                                .foregroundStyle(
                                                    LinearGradient(
                                                        colors: [
                                                            Color.blue.opacity(0.8),
                                                            Color.cyan.opacity(0.7),
                                                            Color.purple.opacity(0.6),
                                                            Color.blue.opacity(0.8)
                                                        ],
                                                        startPoint: .leading,
                                                        endPoint: .trailing
                                                    )
                                                )
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 8)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .fill(.ultraThinMaterial)
                                                        .overlay(
                                                            RoundedRectangle(cornerRadius: 12)
                                                                .stroke(
                                                                    LinearGradient(
                                                                        colors: [
                                                                            Color.blue.opacity(0.3),
                                                                            Color.cyan.opacity(0.2),
                                                                            Color.purple.opacity(0.3)
                                                                        ],
                                                                        startPoint: .topLeading,
                                                                        endPoint: .bottomTrailing
                                                                    ),
                                                                    lineWidth: 1
                                                                )
                                                        )
                                                )
                                                .shadow(color: Color.blue.opacity(0.2), radius: 4, x: 0, y: 2)
                                        } else {
                                            Text("Start your AI training journey with physiological feedback! 🎯")
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                                .foregroundStyle(
                                                    LinearGradient(
                                                        colors: [
                                                            Color.blue.opacity(0.8),
                                                            Color.cyan.opacity(0.7),
                                                            Color.purple.opacity(0.6),
                                                            Color.blue.opacity(0.8)
                                                        ],
                                                        startPoint: .leading,
                                                        endPoint: .trailing
                                                    )
                                                )
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 8)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .fill(.ultraThinMaterial)
                                                        .overlay(
                                                            RoundedRectangle(cornerRadius: 12)
                                                                .stroke(
                                                                    LinearGradient(
                                                                        colors: [
                                                                            Color.blue.opacity(0.3),
                                                                            Color.cyan.opacity(0.2),
                                                                            Color.purple.opacity(0.3)
                                                                        ],
                                                                        startPoint: .topLeading,
                                                                        endPoint: .bottomTrailing
                                                                    ),
                                                                    lineWidth: 1
                                                                )
                                                        )
                                                )
                                                .shadow(color: Color.blue.opacity(0.2), radius: 4, x: 0, y: 2)
                                        }
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
                                        
                                        if watchBridge.isWatchConnected {
                                            HStack {
                                                Text("❤️ \(watchBridge.lastBPM ?? 0) BPM")
                                                    .font(.headline)
                                                    .foregroundColor(.red)
                                                Spacer()
                                                Text("LIVE")
                                                    .font(.caption)
                                                    .fontWeight(.bold)
                                                    .foregroundColor(.green)
                                                    .padding(.horizontal, 8)
                                                    .padding(.vertical, 2)
                                                    .background(Color.green.opacity(0.2))
                                                    .cornerRadius(4)
                                            }
                                        }
                                    }
                                    .padding()
                                    .background(.ultraThinMaterial)
                                    .cornerRadius(16)
                                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                                }

                                // Daily Goal
                                VStack(spacing: 12) {
                                    HStack {
                                        Text("Daily Goal")
                                            .font(.headline)
                                        Spacer()
                                        Text("\(goals.completedToday)/\(goals.dailyTarget)")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.horizontal)
                                    
                                    ProgressView(value: Double(max(0, min(goals.completedToday, goals.dailyTarget))), total: Double(max(1, goals.dailyTarget)))
                                        .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                                        .padding(.horizontal)
                                }
                                .padding()
                                .background(.ultraThinMaterial)
                                .cornerRadius(16)
                                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)

                                // Heart Rate Chart
                                VStack(spacing: 12) {
                                    HStack {
                                        Text("Heart Rate Monitor")
                                            .font(.headline)
                                        Spacer()
                                    }
                                    .padding(.horizontal)
                                    
                                    HeartRateChart(dataPoints: watchBridge.heartRateHistory)
                                        .frame(height: 200)
                                        .padding()
                                        .background(.ultraThinMaterial)
                                        .cornerRadius(16)
                                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                                }
                            }
                            .padding()
                        }
                    }
                    .tag(0)
                    
                    // Tasks Tab
                    TaskPage()
                        .tag(1)
                    
                    // Profile Tab
                    ProfileView()
                        .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 8) {
                        Image(systemName: "brain.head.profile")
                            .font(.title2)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .cyan, .blue, .purple, .blue],
                                    startPoint: UnitPoint(x: 0, y: 0),
                                    endPoint: UnitPoint(x: 1, y: 1)
                                )
                            )
                            .scaleEffect(1.0)
                            .animation(
                                Animation.linear(duration: 2.0)
                                    .repeatForever(autoreverses: false),
                                value: UUID()
                            )
                        
                        Text("Train Your AI")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .cyan, .blue, .purple, .blue],
                                    startPoint: UnitPoint(x: 0, y: 0),
                                    endPoint: UnitPoint(x: 1, y: 1)
                                )
                            )
                            .scaleEffect(1.0)
                            .animation(
                                Animation.linear(duration: 2.0)
                                    .repeatForever(autoreverses: false),
                                value: UUID()
                            )
                    }
                }
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(
                Color.pink.opacity(0.15),
                for: .navigationBar
            )
            .toolbarColorScheme(.light, for: .navigationBar)
        }
        .overlay(alignment: .top) {
            if showConfetti {
                ConfettiView()
                    .frame(height: 240)
                    .transition(.opacity)
            }
        }
        // Update goals when a round completes
        .onReceive(NotificationCenter.default.publisher(for: .taskRoundCompleted)) { note in
            goals.incrementAfterCompletion()
            let reward = (note.userInfo?["reward"] as? Double) ?? 0
            let category = (note.userInfo?["category"] as? String) ?? "Unknown"
            let taskId = (note.userInfo?["taskId"] as? String) ?? "unknown"
            
            // Update neural network in ProfileView
            AuthManager.shared.addCompletedTask(taskId: taskId, category: category, reward: reward)
            
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
        )
    ]
}

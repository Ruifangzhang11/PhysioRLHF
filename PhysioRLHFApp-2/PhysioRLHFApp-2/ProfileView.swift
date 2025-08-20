//
//  ProfileView.swift
//  PhysioRLHFApp-2
//
//  Created by Ruifang Zhang on 8/20/25.
//

import SwiftUI
import Charts

// MARK: - User Model
struct User: Codable {
    let id: String
    var username: String
    var email: String
    var joinDate: Date
    var totalTasks: Int
    var completedTasks: Int
    var totalReward: Double
    var neuralConnections: [NeuralConnection]
    var preferences: UserPreferences
    
    var completionRate: Double {
        guard totalTasks > 0 else { return 0 }
        return Double(completedTasks) / Double(totalTasks)
    }
}

struct UserPreferences: Codable {
    var notificationsEnabled: Bool
    var dailyGoal: Int
    var preferredCategories: [String]
    var theme: String
}

struct NeuralConnection: Codable, Identifiable {
    let id = UUID()
    let taskId: String
    let category: String
    let reward: Double
    let timestamp: Date
    let strength: Double // 0.0 to 1.0
    var isActive: Bool = false
}

// MARK: - Authentication Manager
class AuthManager: ObservableObject {
    static let shared = AuthManager()
    
    private init() {
        // Load saved user on initialization
        if let data = UserDefaults.standard.data(forKey: "currentUser"),
           let user = try? JSONDecoder().decode(User.self, from: data) {
            self.currentUser = user
            self.isAuthenticated = true
        }
    }
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage = ""
    
    func register(username: String, email: String, password: String) async {
        await MainActor.run { isLoading = true; errorMessage = "" }
        
        // Simulate API call
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        await MainActor.run {
            let newUser = User(
                id: UUID().uuidString,
                username: username,
                email: email,
                joinDate: Date(),
                totalTasks: 0,
                completedTasks: 0,
                totalReward: 0.0,
                neuralConnections: [],
                preferences: UserPreferences(
                    notificationsEnabled: true,
                    dailyGoal: 5,
                    preferredCategories: ["Empathy", "Clarity"],
                    theme: "default"
                )
            )
            
            self.currentUser = newUser
            self.isAuthenticated = true
            self.isLoading = false
            
            // Save to UserDefaults
            if let encoded = try? JSONEncoder().encode(newUser) {
                UserDefaults.standard.set(encoded, forKey: "currentUser")
            }
        }
    }
    
    func login(email: String, password: String) async {
        await MainActor.run { isLoading = true; errorMessage = "" }
        
        // Simulate API call
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        await MainActor.run {
            // For demo, create a mock user
            let mockUser = User(
                id: "demo_user",
                username: "DemoUser",
                email: email,
                joinDate: Date().addingTimeInterval(-86400 * 30), // 30 days ago
                totalTasks: 45,
                completedTasks: 38,
                totalReward: 28.5,
                neuralConnections: generateMockConnections(),
                preferences: UserPreferences(
                    notificationsEnabled: true,
                    dailyGoal: 5,
                    preferredCategories: ["Empathy", "Creativity"],
                    theme: "default"
                )
            )
            
            self.currentUser = mockUser
            self.isAuthenticated = true
            self.isLoading = false
            
            // Save to UserDefaults
            if let encoded = try? JSONEncoder().encode(mockUser) {
                UserDefaults.standard.set(encoded, forKey: "currentUser")
            }
        }
    }
    
    func logout() {
        currentUser = nil
        isAuthenticated = false
        UserDefaults.standard.removeObject(forKey: "currentUser")
    }
    
    func addCompletedTask(taskId: String, category: String, reward: Double) {
        guard var user = currentUser else { return }
        
        user.completedTasks += 1
        user.totalReward += reward
        
        let newConnection = NeuralConnection(
            taskId: taskId,
            category: category,
            reward: reward,
            timestamp: Date(),
            strength: reward
        )
        
        user.neuralConnections.append(newConnection)
        currentUser = user
        
        // Save to UserDefaults
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: "currentUser")
        }
    }
    
    private func generateMockConnections() -> [NeuralConnection] {
        let categories = ["Empathy", "Clarity", "Calmness", "Creativity", "Factuality"]
        var connections: [NeuralConnection] = []
        
        for i in 0..<38 {
            let category = categories[i % categories.count]
            let reward = Double.random(in: 0.3...1.0)
            let daysAgo = Double.random(in: 0...30)
            
            connections.append(NeuralConnection(
                taskId: "task_\(i)",
                category: category,
                reward: reward,
                timestamp: Date().addingTimeInterval(-86400 * daysAgo),
                strength: reward
            ))
        }
        
        return connections
    }
}

// MARK: - Profile View
struct ProfileView: View {
    @StateObject private var authManager = AuthManager.shared
    @State private var showingLogin = false
    @State private var showingRegister = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.purple.opacity(0.1),
                    Color.blue.opacity(0.05),
                    Color.indigo.opacity(0.1)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            if authManager.isAuthenticated, let user = authManager.currentUser {
                UserProfileView(user: user, authManager: authManager)
            } else {
                AuthenticationView(
                    authManager: authManager,
                    showingLogin: $showingLogin,
                    showingRegister: $showingRegister
                )
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.large)

    }
}

// MARK: - Authentication View
struct AuthenticationView: View {
    @ObservedObject var authManager: AuthManager
    @Binding var showingLogin: Bool
    @Binding var showingRegister: Bool
    
    var body: some View {
        VStack(spacing: 30) {
            // Logo/Brain Icon
            VStack(spacing: 20) {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 80))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.purple, .blue, .indigo],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                Text("NeuralTrain")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.orange, .yellow, .orange],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                Text("Train Your AI with Physiology")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Auth Buttons
            VStack(spacing: 16) {
                Button(action: { showingLogin = true }) {
                    HStack {
                        Image(systemName: "person.fill")
                        Text("Sign In")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                }
                
                Button(action: { showingRegister = true }) {
                    HStack {
                        Image(systemName: "person.badge.plus")
                        Text("Create Account")
                    }
                    .font(.headline)
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.blue, lineWidth: 1)
                    )
                }
            }
            .padding(.horizontal, 40)
            
            Spacer()
            
            if !authManager.errorMessage.isEmpty {
                Text(authManager.errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding()
            }
        }
        .sheet(isPresented: $showingLogin) {
            LoginView(authManager: authManager)
        }
        .sheet(isPresented: $showingRegister) {
            RegisterView(authManager: authManager)
        }
    }
}

// MARK: - Login View
struct LoginView: View {
    @ObservedObject var authManager: AuthManager
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("Welcome Back")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                VStack(spacing: 16) {
                    TextField("Email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.horizontal)
                
                Button(action: {
                    Task {
                        await authManager.login(email: email, password: password)
                        if authManager.isAuthenticated {
                            dismiss()
                        }
                    }
                }) {
                    if authManager.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Sign In")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
                .padding(.horizontal)
                .disabled(authManager.isLoading)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Login")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Register View
struct RegisterView: View {
    @ObservedObject var authManager: AuthManager
    @Environment(\.dismiss) private var dismiss
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("Create Account")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                VStack(spacing: 16) {
                    TextField("Username", text: $username)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                    
                    TextField("Email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    SecureField("Confirm Password", text: $confirmPassword)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.horizontal)
                
                Button(action: {
                    Task {
                        await authManager.register(username: username, email: email, password: password)
                        if authManager.isAuthenticated {
                            dismiss()
                        }
                    }
                }) {
                    if authManager.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Create Account")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        colors: [.green, .blue],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
                .padding(.horizontal)
                .disabled(authManager.isLoading || password != confirmPassword || password.isEmpty)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Register")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - User Profile View
struct UserProfileView: View {
    let user: User
    @ObservedObject var authManager: AuthManager
    @State private var selectedTab = 0
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 16) {
                    // Profile Info
                    VStack(spacing: 12) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.purple, .blue],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        VStack(spacing: 4) {
                            Text(user.username)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text(user.email)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text("Member since \(user.joinDate.formatted(date: .abbreviated, time: .omitted))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Stats Cards
                    HStack(spacing: 16) {
                        StatCard(
                            title: "Tasks",
                            value: "\(user.completedTasks)/\(user.totalTasks)",
                            icon: "checkmark.circle.fill",
                            color: .green
                        )
                        
                        StatCard(
                            title: "Reward",
                            value: String(format: "%.1f", user.totalReward),
                            icon: "star.fill",
                            color: .orange
                        )
                        
                        StatCard(
                            title: "Rate",
                            value: "\(Int(user.completionRate * 100))%",
                            icon: "chart.line.uptrend.xyaxis",
                            color: .blue
                        )
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(16)
                
                // Tab Picker
                Picker("View", selection: $selectedTab) {
                    Text("Neural Network").tag(0)
                    Text("Task History").tag(1)
                    Text("Settings").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                // Tab Content
                Group {
                    switch selectedTab {
                    case 0:
                        NeuralNetworkView(user: user)
                    case 1:
                        UserTaskHistoryView(user: user)
                    case 2:
                        UserSettingsView(user: user, authManager: authManager)
                    default:
                        NeuralNetworkView(user: user)
                    }
                }
                .frame(minHeight: 400)
            }
            .padding()
        }
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Neural Network View
struct NeuralNetworkView: View {
    let user: User
    @State private var animatedConnections: Set<String> = []
    @State private var animationPhase: Double = 0
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Your Neural Network")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Each completed task adds a neural pathway to your AI training network")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                // High-Tech Neural Network Visualization
                ZStack {
                    // Dark background for circuit board effect
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [Color.black.opacity(0.8), Color.blue.opacity(0.3), Color.black.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 320, height: 320)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(
                                    LinearGradient(
                                        colors: [Color.cyan.opacity(0.6), Color.blue.opacity(0.4)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2
                                )
                        )
                    
                    // Circuit board brain shape
                    CircuitBrainShape()
                        .stroke(
                            LinearGradient(
                                colors: [Color.cyan, Color.blue, Color.cyan],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                        .frame(width: 280, height: 280)
                        .opacity(0.8)
                    
                    // Binary code particles
                    ForEach(0..<20, id: \.self) { index in
                        BinaryParticle(index: index, animationPhase: animationPhase)
                    }
                    
                    // Neural pathway connections
                    ForEach(Array(user.neuralConnections.enumerated()), id: \.element.id) { index, connection in
                        CircuitConnectionView(
                            connection: connection,
                            isActive: animatedConnections.contains(connection.id.uuidString),
                            index: index,
                            total: user.neuralConnections.count
                        )
                    }
                    
                    // Central processing node
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.cyan.opacity(0.8), Color.blue.opacity(0.4), Color.clear],
                                center: .center,
                                startRadius: 5,
                                endRadius: 30
                            )
                        )
                        .frame(width: 60, height: 60)
                        .scaleEffect(1.0 + 0.1 * sin(animationPhase * 2))
                        .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: animationPhase)
                }
                .frame(height: 350)
                
                // Connection Legend
                VStack(alignment: .leading, spacing: 12) {
                    Text("Neural Pathway Types")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    VStack(spacing: 8) {
                        ConnectionLegendItem(color: .cyan, title: "Empathy")
                        ConnectionLegendItem(color: .green, title: "Clarity")
                        ConnectionLegendItem(color: .purple, title: "Calmness")
                        ConnectionLegendItem(color: .orange, title: "Creativity")
                        ConnectionLegendItem(color: .red, title: "Factuality")
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(12)
                .padding(.horizontal)
            }
            .padding()
        }
        .onAppear {
            startNeuralAnimation()
        }
    }
    
    private func startNeuralAnimation() {
        // Continuous animation phase
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            animationPhase += 0.1
        }
        
        // Neural pathway activation
        Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { _ in
            let randomConnection = user.neuralConnections.randomElement()
            if let connection = randomConnection {
                animatedConnections.insert(connection.id.uuidString)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    animatedConnections.remove(connection.id.uuidString)
                }
            }
        }
    }
}

// MARK: - Circuit Brain Shape
struct CircuitBrainShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.width
        let height = rect.height
        let centerX = width / 2
        let centerY = height / 2
        
        // Circuit board brain outline
        path.move(to: CGPoint(x: centerX - 80, y: centerY - 60))
        path.addCurve(
            to: CGPoint(x: centerX - 60, y: centerY + 40),
            control1: CGPoint(x: centerX - 100, y: centerY - 20),
            control2: CGPoint(x: centerX - 80, y: centerY + 20)
        )
        path.addCurve(
            to: CGPoint(x: centerX + 60, y: centerY + 40),
            control1: CGPoint(x: centerX - 40, y: centerY + 60),
            control2: CGPoint(x: centerX + 40, y: centerY + 60)
        )
        path.addCurve(
            to: CGPoint(x: centerX + 80, y: centerY - 60),
            control1: CGPoint(x: centerX + 80, y: centerY + 20),
            control2: CGPoint(x: centerX + 100, y: centerY - 20)
        )
        path.addCurve(
            to: CGPoint(x: centerX - 80, y: centerY - 60),
            control1: CGPoint(x: centerX + 40, y: centerY - 80),
            control2: CGPoint(x: centerX - 40, y: centerY - 80)
        )
        
        // Add circuit board traces
        path.move(to: CGPoint(x: centerX - 40, y: centerY - 40))
        path.addLine(to: CGPoint(x: centerX + 40, y: centerY - 40))
        
        path.move(to: CGPoint(x: centerX - 30, y: centerY - 20))
        path.addLine(to: CGPoint(x: centerX + 30, y: centerY - 20))
        
        path.move(to: CGPoint(x: centerX - 20, y: centerY))
        path.addLine(to: CGPoint(x: centerX + 20, y: centerY))
        
        path.move(to: CGPoint(x: centerX - 30, y: centerY + 20))
        path.addLine(to: CGPoint(x: centerX + 30, y: centerY + 20))
        
        path.move(to: CGPoint(x: centerX - 40, y: centerY + 40))
        path.addLine(to: CGPoint(x: centerX + 40, y: centerY + 40))
        
        return path
    }
}

// MARK: - Binary Particle
struct BinaryParticle: View {
    let index: Int
    let animationPhase: Double
    
    private var position: CGPoint {
        let angle = Double(index) * 0.314 + animationPhase
        let radius = 80.0 + Double(index % 3) * 20
        return CGPoint(
            x: cos(angle) * radius + 160,
            y: sin(angle) * radius + 160
        )
    }
    
    private var binaryText: String {
        ["0", "1"].randomElement() ?? "0"
    }
    
    var body: some View {
        Text(binaryText)
            .font(.caption2)
            .fontWeight(.bold)
            .foregroundColor(.cyan.opacity(0.6))
            .position(position)
            .opacity(0.3 + 0.4 * sin(animationPhase + Double(index)))
            .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: animationPhase)
    }
}

// MARK: - Circuit Connection View
struct CircuitConnectionView: View {
    let connection: NeuralConnection
    let isActive: Bool
    let index: Int
    let total: Int
    
    private var position: CGPoint {
        let angle = Double(index) / Double(total) * 2 * .pi
        let radius = 110.0
        return CGPoint(
            x: cos(angle) * radius + 160,
            y: sin(angle) * radius + 160
        )
    }
    
    private var connectionColor: Color {
        switch connection.category {
        case "Empathy": return .cyan
        case "Clarity": return .green
        case "Calmness": return .purple
        case "Creativity": return .orange
        case "Factuality": return .red
        default: return .gray
        }
    }
    
    var body: some View {
        ZStack {
            // Circuit pathway to center
            Path { path in
                path.move(to: CGPoint(x: 160, y: 160))
                path.addLine(to: position)
            }
            .stroke(
                LinearGradient(
                    colors: [
                        connectionColor.opacity(isActive ? 1.0 : 0.2),
                        connectionColor.opacity(isActive ? 0.8 : 0.1),
                        connectionColor.opacity(isActive ? 1.0 : 0.2)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                lineWidth: isActive ? 4 : 2
            )
            .animation(.easeInOut(duration: 0.8), value: isActive)
            .shadow(color: connectionColor.opacity(isActive ? 0.6 : 0.1), radius: isActive ? 6 : 2)
            
            // Circuit node with glow effect
            ZStack {
                // Outer glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                connectionColor.opacity(isActive ? 0.8 : 0.2),
                                connectionColor.opacity(isActive ? 0.4 : 0.1),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 5,
                            endRadius: 20
                        )
                    )
                    .frame(width: isActive ? 24 : 16, height: isActive ? 24 : 16)
                
                // Inner node
                Circle()
                    .fill(connectionColor)
                    .frame(width: isActive ? 12 : 8, height: isActive ? 12 : 8)
            }
            .position(position)
            .scaleEffect(isActive ? 1.3 : 1.0)
            .animation(.easeInOut(duration: 0.8), value: isActive)
        }
    }
}

// MARK: - Connection Legend Item
struct ConnectionLegendItem: View {
    let color: Color
    let title: String
    
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
        }
    }
}

// MARK: - User Task History View
struct UserTaskHistoryView: View {
    let user: User
    @State private var taskHistory: [TaskHistoryRecord] = []
    @State private var isLoading = true
    @State private var errorMessage = ""
    
    var body: some View {
        ScrollView {
            if isLoading {
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.2)
                    Text("Loading task history...")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.top, 50)
            } else if !errorMessage.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.title)
                        .foregroundColor(.orange)
                    Text(errorMessage)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.top, 50)
            } else if taskHistory.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.title)
                        .foregroundColor(.secondary)
                    Text("No tasks completed yet")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text("Complete your first task to see it here!")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.top, 50)
            } else {
                LazyVStack(spacing: 12) {
                                                    ForEach(taskHistory) { record in
                                    UserTaskHistoryCard(record: record)
                                }
                }
                .padding()
            }
        }
        .onAppear {
            loadTaskHistory()
        }
    }
    
    private func loadTaskHistory() {
        Task {
            do {
                let history = try await SupabaseClient.shared.fetchTaskHistory()
                await MainActor.run {
                    self.taskHistory = history
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to load task history: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
}

// MARK: - User Task History Card
struct UserTaskHistoryCard: View {
    let record: TaskHistoryRecord
    
    var body: some View {
        HStack(spacing: 12) {
            // Category icon
            Image(systemName: categoryIcon)
                .font(.title2)
                .foregroundColor(categoryColor)
                .frame(width: 40, height: 40)
                .background(categoryColor.opacity(0.1))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(record.question)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(2)
                
                Text(record.category)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(record.startTime.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(String(format: "%.2f", record.reward ?? 0.0))
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
                
                Text("Reward")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }
    
    private var categoryIcon: String {
        switch record.category {
        case "Empathy": return "heart.fill"
        case "Clarity": return "list.bullet"
        case "Calmness": return "leaf.fill"
        case "Creativity": return "wand.and.stars"
        case "Factuality": return "checkmark.seal.fill"
        default: return "questionmark.circle"
        }
    }
    
    private var categoryColor: Color {
        switch record.category {
        case "Empathy": return .blue
        case "Clarity": return .green
        case "Calmness": return .purple
        case "Creativity": return .orange
        case "Factuality": return .red
        default: return .gray
        }
    }
}

// MARK: - User Settings View
struct UserSettingsView: View {
    let user: User
    @ObservedObject var authManager: AuthManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Profile Settings
                VStack(alignment: .leading, spacing: 16) {
                    Text("Profile Settings")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    VStack(spacing: 12) {
                        SettingRow(title: "Username", value: user.username, icon: "person")
                        SettingRow(title: "Email", value: user.email, icon: "envelope")
                        SettingRow(title: "Member Since", value: user.joinDate.formatted(date: .abbreviated, time: .omitted), icon: "calendar")
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(12)
                
                // Preferences
                VStack(alignment: .leading, spacing: 16) {
                    Text("Preferences")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    VStack(spacing: 12) {
                        SettingRow(title: "Daily Goal", value: "\(user.preferences.dailyGoal) tasks", icon: "target")
                        SettingRow(title: "Notifications", value: user.preferences.notificationsEnabled ? "On" : "Off", icon: "bell")
                        SettingRow(title: "Theme", value: user.preferences.theme.capitalized, icon: "paintbrush")
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(12)
                
                // Logout Button
                Button(action: {
                    authManager.logout()
                }) {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                        Text("Sign Out")
                    }
                    .font(.headline)
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.red, lineWidth: 1)
                    )
                }
            }
            .padding()
        }
    }
}

// MARK: - Setting Row
struct SettingRow: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            
            Text(title)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(value)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    ProfileView()
}

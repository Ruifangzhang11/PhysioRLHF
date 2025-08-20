//
//  TaskPage.swift
//  PhysioRLHFApp-2
//
//  Created by Ruifang Zhang on 8/20/25.
//

import SwiftUI

struct TaskPage: View {
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
            
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 12) {
                        HStack {
                            Text("Task Categories")
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
                        }
                        
                        Text("Choose a category to start training your LLM")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal)
                    
                    // Categories Grid
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        ForEach(categories) { category in
                            NavigationLink {
                                TaskView(title: category.title, tasks: category.tasks)
                            } label: {
                                VStack(spacing: 12) {
                                    // Icon
                                    Image(systemName: category.icon)
                                        .font(.system(size: 32))
                                        .foregroundColor(Color(hex: category.colorHex))
                                        .frame(width: 60, height: 60)
                                        .background(Color(hex: category.colorHex).opacity(0.1))
                                        .cornerRadius(16)
                                    
                                    // Title
                                    Text(category.title)
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.primary)
                                    
                                    // Subtitle
                                    Text(category.subtitle)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                        .lineLimit(2)
                                    
                                    // Task count
                                    Text("\(category.tasks.count) tasks")
                                        .font(.caption2)
                                        .fontWeight(.medium)
                                        .foregroundColor(Color(hex: category.colorHex))
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color(hex: category.colorHex).opacity(0.1))
                                        .cornerRadius(8)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(20)
                                .background(.ultraThinMaterial)
                                .cornerRadius(20)
                                .shadow(color: Color.black.opacity(0.1), radius: 15, x: 0, y: 8)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                    
                    // Quick Actions
                    VStack(spacing: 16) {
                        HStack {
                            Text("Quick Actions")
                                .font(.headline)
                                .fontWeight(.semibold)
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        HStack(spacing: 16) {
                            NavigationLink {
                                TaskView(title: "Quick Start", tasks: DemoPools.empathy)
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "bolt.fill")
                                        .font(.title3)
                                    Text("Quick Start")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(12)
                            }
                            
                            NavigationLink {
                                HistoryView()
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "clock.arrow.circlepath")
                                        .font(.title3)
                                    Text("History")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                }
                                .foregroundColor(.primary)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(.ultraThinMaterial)
                                .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer(minLength: 50)
                }
                .padding(.vertical)
            }
        }
    }
}

#Preview {
    TaskPage()
        .environmentObject(WatchHRBridge.shared)
}

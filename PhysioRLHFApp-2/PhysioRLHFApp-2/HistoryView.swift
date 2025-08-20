//
//  HistoryView.swift
//  PhysioRLHFApp-2
//
//  Created by Ruifang Zhang on 8/20/25.
//

import SwiftUI
import Charts

// MARK: - Task History Data Model
struct TaskHistoryRecord: Identifiable, Codable {
    let id = UUID()
    let taskId: String
    let category: String
    let question: String
    let optionAContent: String
    let optionBContent: String
    let userChoice: String
    let startTime: Date
    let endTime: Date
    let optionAHeartRate: [Int]
    let optionBHeartRate: [Int]
    let reward: Double
    let meta: [String: String]
    
    var duration: TimeInterval {
        endTime.timeIntervalSince(startTime)
    }
    
    var optionADuration: TimeInterval {
        // Parse stages from meta to get optionA duration
        if let stages = meta["stages"] {
            let components = stages.components(separatedBy: "|")
            if components.count >= 1 {
                let optionAComponent = components[0]
                if let startIndex = optionAComponent.firstIndex(of: "("),
                   let endIndex = optionAComponent.lastIndex(of: ")") {
                    let durationString = String(optionAComponent[optionAComponent.index(after: startIndex)..<endIndex])
                    return Double(durationString) ?? 20.0
                }
            }
        }
        return 20.0 // Default fallback
    }
    
    var optionBDuration: TimeInterval {
        // Parse stages from meta to get optionB duration
        if let stages = meta["stages"] {
            let components = stages.components(separatedBy: "|")
            if components.count >= 2 {
                let optionBComponent = components[1]
                if let startIndex = optionBComponent.firstIndex(of: "("),
                   let endIndex = optionBComponent.lastIndex(of: ")") {
                    let durationString = String(optionBComponent[optionBComponent.index(after: startIndex)..<endIndex])
                    return Double(durationString) ?? 20.0
                }
            }
        }
        return 20.0 // Default fallback
    }
}

// MARK: - History View
struct HistoryView: View {
    @State private var taskHistory: [TaskHistoryRecord] = []
    @State private var isLoading = false
    @State private var selectedRecord: TaskHistoryRecord?
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
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
                
                if isLoading {
                    ProgressView("Loading history...")
                        .scaleEffect(1.2)
                } else if taskHistory.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        
                        Text("No Task History")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Complete some tasks to see your heart rate data and choices here.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(taskHistory) { record in
                                TaskHistoryCard(record: record) {
                                    selectedRecord = record
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Task History")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                loadTaskHistory()
            }
            .sheet(item: $selectedRecord) { record in
                TaskDetailView(record: record)
            }
        }
    }
    
    private func loadTaskHistory() {
        isLoading = true
        
        Task {
            do {
                let records = try await SupabaseClient.shared.fetchTaskHistory()
                await MainActor.run {
                    self.taskHistory = records
                    self.isLoading = false
                }
            } catch {
                print("❌ Failed to load task history: \(error)")
                await MainActor.run {
                    self.isLoading = false
                }
            }
        }
    }
}

// MARK: - Task History Card
struct TaskHistoryCard: View {
    let record: TaskHistoryRecord
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(record.category)
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text(record.question)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(record.userChoice)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(record.userChoice == "A" ? .blue : .green)
                            .frame(width: 40, height: 40)
                            .background(
                                Circle()
                                    .fill(record.userChoice == "A" ? Color.blue.opacity(0.2) : Color.green.opacity(0.2))
                            )
                        
                        Text("Choice")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Heart Rate Summary
                HStack(spacing: 20) {
                    HeartRateSummary(
                        title: "Option A",
                        data: record.optionAHeartRate,
                        color: .blue
                    )
                    
                    HeartRateSummary(
                        title: "Option B", 
                        data: record.optionBHeartRate,
                        color: .green
                    )
                }
                
                // Footer
                HStack {
                    Text(record.startTime, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("Reward: \(String(format: "%.2f", record.reward))")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.orange)
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Heart Rate Summary
struct HeartRateSummary: View {
    let title: String
    let data: [Int]
    let color: Color
    
    var averageBPM: Int {
        guard !data.isEmpty else { return 0 }
        return data.reduce(0, +) / data.count
    }
    
    var maxBPM: Int {
        data.max() ?? 0
    }
    
    var minBPM: Int {
        data.min() ?? 0
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(color)
            
            if data.isEmpty {
                Text("No data")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            } else {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(averageBPM) BPM")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Text("\(minBPM)-\(maxBPM)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Text("\(data.count) samples")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Task Detail View
struct TaskDetailView: View {
    let record: TaskHistoryRecord
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 12) {
                        Text(record.category)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text(record.question)
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Text("Your Choice:")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text(record.userChoice)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(record.userChoice == "A" ? .blue : .green)
                                .frame(width: 50, height: 50)
                                .background(
                                    Circle()
                                        .fill(record.userChoice == "A" ? Color.blue.opacity(0.2) : Color.green.opacity(0.2))
                                )
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(16)
                    
                    // Options Content
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Task Options")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            // Option A
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Option A")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.blue)
                                    
                                    if record.userChoice == "A" {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.blue)
                                    }
                                    
                                    Spacer()
                                }
                                
                                Text(record.optionAContent)
                                    .font(.body)
                                    .padding()
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(8)
                            }
                            
                            // Option B
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Option B")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.green)
                                    
                                    if record.userChoice == "B" {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                    }
                                    
                                    Spacer()
                                }
                                
                                Text(record.optionBContent)
                                    .font(.body)
                                    .padding()
                                    .background(Color.green.opacity(0.1))
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(16)
                    
                    // Combined Heart Rate Chart
                    CombinedHeartRateChartView(
                        optionAData: record.optionAHeartRate,
                        optionBData: record.optionBHeartRate
                    )
                    
                    // Statistics Bar Chart
                    StatisticsBarChartView(
                        title: "Heart Rate Statistics",
                        optionAData: record.optionAHeartRate,
                        optionBData: record.optionBHeartRate
                    )
                    
                    // Metadata
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Task Details")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            DetailRow(label: "Start Time", value: record.startTime.formatted(date: .abbreviated, time: .shortened))
                            DetailRow(label: "End Time", value: record.endTime.formatted(date: .abbreviated, time: .shortened))
                            DetailRow(label: "Duration", value: "\(Int(record.duration))s")
                            DetailRow(label: "Reward", value: String(format: "%.2f", record.reward))
                            DetailRow(label: "App Version", value: record.meta["app_version"] ?? "Unknown")
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(16)
                }
                .padding()
            }
            .navigationTitle("Task Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Combined Heart Rate Chart View
struct CombinedHeartRateChartView: View {
    let optionAData: [Int]
    let optionBData: [Int]
    
    var combinedChartData: [CombinedHeartRateDataPoint] {
        var dataPoints: [CombinedHeartRateDataPoint] = []
        
        // Add Option A data points
        for (index, bpm) in optionAData.enumerated() {
            dataPoints.append(CombinedHeartRateDataPoint(
                timestamp: Date().addingTimeInterval(Double(index) * 2.0),
                heartRate: bpm,
                option: "A"
            ))
        }
        
        // Add Option B data points (continue from where A left off)
        for (index, bpm) in optionBData.enumerated() {
            dataPoints.append(CombinedHeartRateDataPoint(
                timestamp: Date().addingTimeInterval(Double(optionAData.count + index) * 2.0),
                heartRate: bpm,
                option: "B"
            ))
        }
        
        return dataPoints
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Heart Rate Comparison")
                .font(.headline)
                .fontWeight(.semibold)
            
            // Legend
            HStack(spacing: 20) {
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 12, height: 12)
                    Text("Option A")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 12, height: 12)
                    Text("Option B")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                
                Spacer()
            }
            
            if optionAData.isEmpty && optionBData.isEmpty {
                Text("No heart rate data available")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
            } else {
                CombinedHeartRateChart(dataPoints: combinedChartData)
                    .frame(height: 200)
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(12)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
    }
}

// MARK: - Combined Heart Rate Data Point
struct CombinedHeartRateDataPoint: Identifiable {
    let id = UUID()
    let timestamp: Date
    let heartRate: Int
    let option: String
}

// MARK: - Combined Heart Rate Chart
struct CombinedHeartRateChart: View {
    let dataPoints: [CombinedHeartRateDataPoint]
    
    var body: some View {
        Chart {
            ForEach(dataPoints) { point in
                LineMark(
                    x: .value("Time", point.timestamp),
                    y: .value("Heart Rate", point.heartRate)
                )
                .foregroundStyle(by: .value("Option", point.option))
            }
        }
        .chartForegroundStyleScale([
            "A": Color.blue,
            "B": Color.green
        ])
        .chartXAxis {
            AxisMarks(position: .bottom) { value in
                AxisGridLine()
                AxisValueLabel(format: .dateTime.minute().second())
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisGridLine()
                AxisValueLabel()
            }
        }
    }
}

// MARK: - Statistics Bar Chart View
struct StatisticsBarChartView: View {
    let title: String
    let optionAData: [Int]
    let optionBData: [Int]
    
    var optionAStats: (average: Double, median: Double, mode: Double) {
        calculateStats(data: optionAData)
    }
    
    var optionBStats: (average: Double, median: Double, mode: Double) {
        calculateStats(data: optionBData)
    }
    
    private func calculateStats(data: [Int]) -> (average: Double, median: Double, mode: Double) {
        guard !data.isEmpty else { return (0, 0, 0) }
        
        // Average
        let average = Double(data.reduce(0, +)) / Double(data.count)
        
        // Median
        let sortedData = data.sorted()
        let median: Double
        if sortedData.count % 2 == 0 {
            median = Double(sortedData[sortedData.count / 2 - 1] + sortedData[sortedData.count / 2]) / 2.0
        } else {
            median = Double(sortedData[sortedData.count / 2])
        }
        
        // Mode (most frequent value)
        let frequencyDict = Dictionary(grouping: data, by: { $0 })
        let mode = frequencyDict.max(by: { $0.value.count < $1.value.count })?.key ?? data[0]
        
        return (average, median, Double(mode))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
            
            if optionAData.isEmpty && optionBData.isEmpty {
                Text("No data available for statistics")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
            } else {
                HStack(spacing: 12) {
                    // Average Chart
                    CompactStatBarChart(
                        title: "Average",
                        optionAValue: optionAStats.average,
                        optionBValue: optionBStats.average,
                        optionAColor: .blue,
                        optionBColor: .green
                    )
                    
                    // Median Chart
                    CompactStatBarChart(
                        title: "Median",
                        optionAValue: optionAStats.median,
                        optionBValue: optionBStats.median,
                        optionAColor: .blue,
                        optionBColor: .green
                    )
                    
                    // Mode Chart
                    CompactStatBarChart(
                        title: "Mode",
                        optionAValue: optionAStats.mode,
                        optionBValue: optionBStats.mode,
                        optionAColor: .blue,
                        optionBColor: .green
                    )
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
    }
}

// MARK: - Compact Stat Bar Chart
struct CompactStatBarChart: View {
    let title: String
    let optionAValue: Double
    let optionBValue: Double
    let optionAColor: Color
    let optionBColor: Color
    
    var maxValue: Double {
        max(optionAValue, optionBValue, 1.0) // Ensure we don't divide by zero
    }
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            // Bars
            HStack(spacing: 6) {
                // Option A Bar
                VStack(spacing: 2) {
                    ZStack(alignment: .bottom) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 20, height: 80)
                            .cornerRadius(3)
                        
                        Rectangle()
                            .fill(optionAColor)
                            .frame(width: 20, height: 80 * (optionAValue / maxValue))
                            .cornerRadius(3)
                    }
                    
                    Text("A")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(optionAColor)
                }
                
                // Option B Bar
                VStack(spacing: 2) {
                    ZStack(alignment: .bottom) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 20, height: 80)
                            .cornerRadius(3)
                        
                        Rectangle()
                            .fill(optionBColor)
                            .frame(width: 20, height: 80 * (optionBValue / maxValue))
                            .cornerRadius(3)
                    }
                    
                    Text("B")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(optionBColor)
                }
            }
            
            // Values
            HStack(spacing: 6) {
                Text(String(format: "%.0f", optionAValue))
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .frame(width: 20)
                
                Text(String(format: "%.0f", optionBValue))
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .frame(width: 20)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Detail Row
struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

#Preview {
    HistoryView()
}

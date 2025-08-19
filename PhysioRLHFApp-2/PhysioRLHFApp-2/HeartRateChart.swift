//
//  HeartRateChart.swift
//  PhysioRLHFApp-2
//
//  Created by Ruifang Zhang on 8/18/25.
//

import SwiftUI
import Charts

struct HeartRateChart: View {
    let dataPoints: [HeartRateDataPoint]
    let maxDataPoints: Int = 50 // Display last 50 data points
    
    private var displayData: [HeartRateDataPoint] {
        if dataPoints.count <= maxDataPoints {
            return dataPoints
        } else {
            return Array(dataPoints.suffix(maxDataPoints))
        }
    }
    
    private var minHeartRate: Int {
        displayData.map { $0.heartRate }.min() ?? 60
    }
    
    private var maxHeartRate: Int {
        displayData.map { $0.heartRate }.max() ?? 100
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Heart Rate Trend")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                // Real-time indicator
                if !dataPoints.isEmpty {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
                            .scaleEffect(1.0)
                            .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: dataPoints.count)
                        
                        Text("LIVE")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                }
            }
            
            if displayData.isEmpty {
                // Empty state
                VStack(spacing: 12) {
                    Image(systemName: "heart.fill")
                        .font(.largeTitle)
                        .foregroundColor(.red.opacity(0.3))
                    
                    Text("Waiting for heart rate data...")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(height: 120)
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
            } else {
                // Heart rate chart
                Chart(displayData) { dataPoint in
                    LineMark(
                        x: .value("Time", dataPoint.timestamp),
                        y: .value("BPM", dataPoint.heartRate)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.red.opacity(0.8), .pink.opacity(0.6)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .lineStyle(StrokeStyle(lineWidth: 2))
                    
                    AreaMark(
                        x: .value("Time", dataPoint.timestamp),
                        y: .value("BPM", dataPoint.heartRate)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.red.opacity(0.2), .pink.opacity(0.1)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
                .frame(height: 120)
                .chartYScale(domain: max(minHeartRate - 10, 30)...min(maxHeartRate + 10, 200))
                .chartXAxis {
                    AxisMarks(values: .stride(by: .minute, count: 1)) { _ in
                        AxisGridLine()
                        AxisTick()
                    }
                }
                .chartYAxis {
                    AxisMarks { value in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel {
                            if let bpm = value.as(Int.self) {
                                Text("\(bpm)")
                                    .font(.caption)
                            }
                        }
                    }
                }
                
                // Statistics
                HStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Current")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(dataPoints.last?.heartRate ?? 0) bpm")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.red)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Average")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(averageHeartRate) bpm")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Range")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(minHeartRate)-\(maxHeartRate)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground).opacity(0.1))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    private var averageHeartRate: Int {
        guard !displayData.isEmpty else { return 0 }
        let sum = displayData.reduce(0) { $0 + $1.heartRate }
        return sum / displayData.count
    }
}

struct HeartRateChart_Previews: PreviewProvider {
    static var previews: some View {
        let sampleData = [
            HeartRateDataPoint(timestamp: Date().addingTimeInterval(-300), heartRate: 72),
            HeartRateDataPoint(timestamp: Date().addingTimeInterval(-240), heartRate: 75),
            HeartRateDataPoint(timestamp: Date().addingTimeInterval(-180), heartRate: 78),
            HeartRateDataPoint(timestamp: Date().addingTimeInterval(-120), heartRate: 82),
            HeartRateDataPoint(timestamp: Date().addingTimeInterval(-60), heartRate: 85),
            HeartRateDataPoint(timestamp: Date(), heartRate: 88)
        ]
        
        VStack(spacing: 20) {
            HeartRateChart(dataPoints: sampleData)
            HeartRateChart(dataPoints: [])
        }
        .padding()
    }
}

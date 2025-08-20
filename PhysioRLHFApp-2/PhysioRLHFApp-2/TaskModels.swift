//
//  TaskModels.swift
//  PhysioRLHFApp-2
//
//  Created by Ruifang Zhang on 8/13/25.
//

import Foundation

// A paired A/B task with enforced durations
public struct PairTask: Identifiable {
    public let id = UUID()
    public let question: String
    public let optionA: String
    public let optionB: String
    public let secReadA: Int
    public let secReadB: Int
    public let secDecide: Int
}

// Category meta used on Home
public struct TaskCategory: Identifiable {
    public let id = UUID()
    public let title: String
    public let subtitle: String
    public let icon: String
    public let colorHex: String
    public let tasks: [PairTask]
}

// Task History Record for storing and displaying completed tasks
public struct TaskHistoryRecord: Identifiable, Codable {
    public let taskId: String
    public let category: String
    public let question: String
    public let optionAContent: String
    public let optionBContent: String
    public let userChoice: String
    public let startTime: Date
    public let endTime: Date
    public let optionAHeartRate: [Int]
    public let optionBHeartRate: [Int]
    public let reward: Double?
    public let meta: [String: String]
    
    public var id: String { taskId }
    public var duration: TimeInterval { endTime.timeIntervalSince(startTime) }
    public var optionADuration: TimeInterval {
        if let stages = meta["stages"], let aDurationStr = stages.split(separator: "|").first?.replacingOccurrences(of: "A(", with: "").replacingOccurrences(of: ")", with: ""), let duration = Double(aDurationStr) {
            return duration
        }
        return 0
    }
    public var optionBDuration: TimeInterval {
        if let stages = meta["stages"], let bDurationStr = stages.split(separator: "|").dropFirst().first?.replacingOccurrences(of: "B(", with: "").replacingOccurrences(of: ")", with: ""), let duration = Double(bDurationStr) {
            return duration
        }
        return 0
    }
}

// Helper
extension String {
    var linesCount: Int { self.split(separator: "\n").count }
}

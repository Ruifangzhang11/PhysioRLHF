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

// Helper
extension String {
    var linesCount: Int { self.split(separator: "\n").count }
}

//
//  SharedTypes.swift
//  PhysioRLHFApp-2
//
//  Created by Ruifang Zhang on 8/19/25.
//

import Foundation

// Shared data type definitions
struct HeartRateDataPoint: Identifiable {
    let id = UUID()
    let timestamp: Date
    let heartRate: Int
}

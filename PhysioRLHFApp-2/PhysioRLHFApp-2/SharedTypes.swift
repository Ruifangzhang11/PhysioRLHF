//
//  SharedTypes.swift
//  PhysioRLHFApp-2
//
//  Created by Ruifang Zhang on 8/19/25.
//

import Foundation

// 共享的数据类型定义
struct HeartRateDataPoint: Identifiable {
    let id = UUID()
    let timestamp: Date
    let heartRate: Int
}

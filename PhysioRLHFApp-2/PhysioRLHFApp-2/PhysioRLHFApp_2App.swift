//
//  PhysioRLHFApp_2App.swift
//  PhysioRLHFApp-2
//
//  Created by Ruifang Zhang on 8/8/25.
//

import SwiftUI

@main
struct PhysioRLHFApp_2App: App {
    // 在App级别管理WatchHRBridge，避免在子视图中重复创建
    @StateObject private var watchBridge = WatchHRBridge.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(watchBridge)
        }
    }
}

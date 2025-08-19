//
//  PhysioRLHF_iOSApp.swift
//  PhysioRLHF iOS
//
//  Created by Ruifang Zhang on 8/13/25.
//

import SwiftUI

@main
struct PhysioRLHF_iOSApp: App {
    // 在App级别管理WatchHRBridge，避免在子视图中重复创建
    @StateObject private var watchBridge = WatchHRBridge.shared
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(watchBridge)
        }
    }
}



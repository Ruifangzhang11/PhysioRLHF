//
//  PhysioRLHF_iOSApp.swift
//  PhysioRLHF iOS
//
//  Created by Ruifang Zhang on 8/13/25.
//

import SwiftUI

@main
struct PhysioRLHF_iOSApp: App {
    // Manage WatchHRBridge at App level to avoid repeated creation in child views
    @StateObject private var watchBridge = WatchHRBridge.shared
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(watchBridge)
        }
    }
}



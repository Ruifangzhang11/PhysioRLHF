//
//  PhysioRLHFApp_2App.swift
//  PhysioRLHFApp-2
//
//  Created by Ruifang Zhang on 8/8/25.
//

import SwiftUI

@main
struct PhysioRLHFApp_2App: App {
    // Manage WatchHRBridge at App level to avoid repeated creation in child views
    @StateObject private var watchBridge = WatchHRBridge.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(watchBridge)
        }
    }
}

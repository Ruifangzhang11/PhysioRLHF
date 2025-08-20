//
//  PhysioRLHFApp_2App.swift
//  PhysioRLHFApp-2
//
//  Created by Ruifang Zhang on 8/8/25.
//

import SwiftUI
import UIKit

@main
struct PhysioRLHFApp_2App: App {
    // Manage WatchHRBridge at App level to avoid repeated creation in child views
    @StateObject private var watchBridge = WatchHRBridge.shared
    
    // Register for background app refresh
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(watchBridge)
        }
    }
}

// AppDelegate for background processing
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        print("📱 iOS App launched")
        
        // Request background app refresh permission
        if UIApplication.shared.backgroundRefreshStatus == .available {
            print("✅ Background app refresh is available")
        } else {
            print("⚠️ Background app refresh is not available")
        }
        
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        print("📱 iOS App entered background")
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        print("📱 iOS App will enter foreground")
    }
}

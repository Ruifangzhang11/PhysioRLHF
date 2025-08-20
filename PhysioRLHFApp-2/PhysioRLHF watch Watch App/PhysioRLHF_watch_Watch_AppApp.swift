//
//  PhysioRLHF_watch_Watch_AppApp.swift
//  PhysioRLHF watch Watch App
//
//  Created by Ruifang Zhang on 8/15/25.
//

import SwiftUI
import WatchKit

@main
struct PhysioRLHF_watch_Watch_AppApp: App {
    @WKExtensionDelegateAdaptor(ExtensionDelegate.self) var extensionDelegate
    
    var body: some Scene {
        WindowGroup {
            HomeView()
        }
    }
}


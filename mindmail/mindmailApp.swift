//
//  mindmailApp.swift
//  mindmail
//
//  Created by Christian Cattaneo on 10/23/25.
//

import SwiftUI
import UserNotifications

@main
struct mindmailApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

/// App Delegate to set up notification handling
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        print("🚀 [AppDelegate] App launched")
        
        // Set notification delegate to handle incoming notifications
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
        print("✅ [AppDelegate] Notification delegate set")
        
        // Check for letters that should have been delivered while app was closed
        Task { @MainActor in
            print("🔍 [AppDelegate] Checking for past-due letters...")
            LetterDeliveryService.shared.checkAndDeliverPastDueLetters()
        }
        
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        print("👀 [AppDelegate] App became active")
        
        // Check again when app comes to foreground
        Task { @MainActor in
            LetterDeliveryService.shared.checkAndDeliverPastDueLetters()
        }
    }
}

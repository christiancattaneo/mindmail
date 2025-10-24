//
//  NotificationDelegate.swift
//  mindmail
//
//  Created by Christian Cattaneo on 10/24/25.
//

import Foundation
import UserNotifications

/// Handles incoming notifications and marks letters as delivered
/// This is the CRITICAL missing piece - without this, letters stay "scheduled" forever
class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    
    static let shared = NotificationDelegate()
    
    private let storage = StorageService.shared
    
    private override init() {
        super.init()
    }
    
    /// Called when app is in foreground and notification arrives
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        print("🔔 [NotificationDelegate] Notification will present - ID: \(notification.request.identifier)")
        
        handleNotification(notification)
        
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }
    
    /// Called when user taps notification
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        print("🔔 [NotificationDelegate] Notification tapped - ID: \(response.notification.request.identifier)")
        
        handleNotification(response.notification)
        
        completionHandler()
    }
    
    /// Handles the notification by marking letter as delivered
    nonisolated private func handleNotification(_ notification: UNNotification) {
        print("📬 [NotificationDelegate] Handling notification...")
        
        guard let letterIdString = notification.request.content.userInfo["letterId"] as? String,
              let letterId = UUID(uuidString: letterIdString) else {
            print("❌ [NotificationDelegate] Invalid letter ID in notification")
            return
        }
        
        print("📬 [NotificationDelegate] Letter ID: \(letterId)")
        
        do {
            print("📬 [NotificationDelegate] Marking letter as delivered...")
            try storage.markLetterAsDelivered(letterId)
            print("✅ [NotificationDelegate] Letter marked as delivered!")
            
            // Post notification to refresh inbox view
            NotificationCenter.default.post(name: .letterDelivered, object: letterId)
            
        } catch {
            print("❌ [NotificationDelegate] Failed to mark as delivered: \(error)")
        }
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let letterDelivered = Notification.Name("letterDelivered")
}


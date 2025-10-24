//
//  NotificationService.swift
//  mindmail
//
//  Created by Christian Cattaneo on 10/24/25.
//

import Foundation
import UserNotifications

/// Manages local notifications for letter delivery
/// Security: Enforces strict limits to prevent abuse and loops
/// - Max 100 scheduled notifications (enforced at storage level)
/// - Minimum 1-minute delay (enforced at model level)
/// - No self-triggering loops (one-way notifications only)
class NotificationService {
    
    // MARK: - Singleton
    static let shared = NotificationService()
    
    private let center = UNUserNotificationCenter.current()
    
    // MARK: - Permission Management
    
    /// Requests notification permissions from the user
    /// - Returns: true if granted, false otherwise
    func requestPermission() async throws -> Bool {
        let settings = await center.notificationSettings()
        
        switch settings.authorizationStatus {
        case .authorized, .provisional:
            return true
            
        case .notDetermined:
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
            
        case .denied, .ephemeral:
            return false
            
        @unknown default:
            return false
        }
    }
    
    /// Checks current notification permission status
    /// - Returns: true if authorized
    func hasPermission() async -> Bool {
        let settings = await center.notificationSettings()
        return settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional
    }
    
    // MARK: - Letter Notifications
    
    /// Schedules a notification for a letter
    /// - Parameter letter: The letter to schedule notification for
    /// - Throws: LetterError if scheduling fails
    func scheduleLetter (_ letter: Letter) throws {
        // Safety check: Ensure date is in the future (already validated at model level)
        guard letter.scheduledDate.timeIntervalSinceNow >= Letter.minScheduleDelay else {
            throw LetterError.scheduledDateMustBeInFuture
        }
        
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "You have a letter from past you! 💌"
        content.body = letter.subject ?? "Open MindMail to read your message"
        content.sound = .default
        content.userInfo = ["letterId": letter.id.uuidString]
        
        // Create trigger based on recurrence
        let trigger: UNNotificationTrigger
        
        switch letter.recurrence {
        case .once:
            // One-time notification
            let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: letter.scheduledDate)
            trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            
        case .daily:
            // Daily repeating notification at same time each day
            let components = Calendar.current.dateComponents([.hour, .minute], from: letter.scheduledDate)
            trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        }
        
        // Create request with letter ID as identifier
        let request = UNNotificationRequest(
            identifier: letter.id.uuidString,
            content: content,
            trigger: trigger
        )
        
        // Schedule notification
        center.add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
    
    /// Cancels a scheduled notification for a letter
    /// - Parameter letterId: UUID of the letter
    func cancelLetter(_ letterId: UUID) {
        center.removePendingNotificationRequests(withIdentifiers: [letterId.uuidString])
    }
    
    /// Cancels all pending notifications
    /// WARNING: This removes ALL app notifications
    func cancelAllNotifications() {
        center.removeAllPendingNotificationRequests()
    }
    
    /// Gets count of pending notifications
    /// - Returns: Number of pending notifications
    func getPendingNotificationCount() async -> Int {
        let requests = await center.pendingNotificationRequests()
        return requests.count
    }
    
    /// Reschedules all letters from storage
    /// Useful after app reinstall or notification permission change
    func rescheduleAllLetters(from storage: StorageService = .shared) async throws {
        // Cancel all existing
        cancelAllNotifications()
        
        // Load all scheduled letters
        let letters = try storage.loadScheduledLetters()
        
        // Reschedule each one
        for letter in letters {
            // Skip if in the past
            guard letter.scheduledDate.timeIntervalSinceNow >= 0 else {
                continue
            }
            
            try scheduleLetter(letter)
        }
    }
}


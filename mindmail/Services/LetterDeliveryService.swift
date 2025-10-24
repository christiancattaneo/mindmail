//
//  LetterDeliveryService.swift
//  mindmail
//
//  Created by Christian Cattaneo on 10/24/25.
//

import Foundation

/// Checks for letters that should have been delivered but weren't
/// Handles missed notifications (app was closed, simulator issues, etc.)
@MainActor
class LetterDeliveryService {
    
    static let shared = LetterDeliveryService()
    
    private let storage = StorageService.shared
    
    private init() {}
    
    /// Checks all scheduled letters and marks past-due ones as delivered
    /// Call this on app launch and when inbox appears
    func checkAndDeliverPastDueLetters() {
        print("📬 [LetterDeliveryService] Checking for past-due letters...")
        
        do {
            let scheduledLetters = try storage.loadScheduledLetters()
            print("📬 [LetterDeliveryService] Found \(scheduledLetters.count) scheduled letters")
            
            let now = Date()
            var deliveredCount = 0
            
            for letter in scheduledLetters {
                // Check if scheduled time has passed
                if letter.scheduledDate <= now {
                    print("📬 [LetterDeliveryService] Letter \(letter.id) is past-due (scheduled: \(letter.scheduledDate))")
                    print("📬 [LetterDeliveryService] Marking as delivered...")
                    
                    try storage.markLetterAsDelivered(letter.id)
                    deliveredCount += 1
                    
                    print("✅ [LetterDeliveryService] Letter \(letter.id) marked as delivered")
                    
                    // Post notification to refresh inbox
                    NotificationCenter.default.post(name: .letterDelivered, object: letter.id)
                }
            }
            
            if deliveredCount > 0 {
                print("🎉 [LetterDeliveryService] Delivered \(deliveredCount) past-due letter(s)")
            } else {
                print("✅ [LetterDeliveryService] No past-due letters found")
            }
            
        } catch {
            print("❌ [LetterDeliveryService] Error checking letters: \(error)")
        }
    }
}


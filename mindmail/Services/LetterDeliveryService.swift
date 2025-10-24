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
        let now = Date()
        print("📬 [LetterDeliveryService] ===== CHECKING PAST-DUE LETTERS =====")
        print("📬 [LetterDeliveryService] Current time: \(now)")
        
        do {
            let scheduledLetters = try storage.loadScheduledLetters()
            print("📬 [LetterDeliveryService] Found \(scheduledLetters.count) scheduled letters")
            
            var deliveredCount = 0
            
            for letter in scheduledLetters {
                let timeUntilDelivery = letter.scheduledDate.timeIntervalSince(now)
                print("📬 [LetterDeliveryService] Letter \(letter.id):")
                print("   - Scheduled for: \(letter.scheduledDate)")
                print("   - Time until delivery: \(timeUntilDelivery) seconds")
                
                // Check if scheduled time has passed
                if letter.scheduledDate <= now {
                    print("   ⏰ PAST-DUE! Delivering now...")
                    
                    try storage.markLetterAsDelivered(letter.id)
                    deliveredCount += 1
                    
                    print("   ✅ Marked as delivered")
                    
                    // Post notification to refresh inbox
                    NotificationCenter.default.post(name: .letterDelivered, object: letter.id)
                } else {
                    print("   ⏳ Still waiting (\(Int(timeUntilDelivery/60)) minutes)")
                }
            }
            
            if deliveredCount > 0 {
                print("🎉 [LetterDeliveryService] Delivered \(deliveredCount) past-due letter(s)!")
            } else {
                print("✅ [LetterDeliveryService] No past-due letters - all still waiting")
            }
            
        } catch {
            print("❌ [LetterDeliveryService] Error checking letters: \(error)")
        }
        
        print("📬 [LetterDeliveryService] ===== CHECK COMPLETE =====")
    }
}


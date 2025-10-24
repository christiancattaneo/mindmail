//
//  ComposeLetterViewModel.swift
//  mindmail
//
//  Created by Christian Cattaneo on 10/24/25.
//

import Foundation

/// Manages letter composition state and validation
@MainActor
@Observable
class ComposeLetterViewModel {
    private let storage: StorageService
    private let notificationService: NotificationService
    
    // Letter data
    var subject: String = ""
    var body: String = ""
    var scheduledDate: Date
    var recurrence: RecurrencePattern = .once
    
    // State
    var showPermissionAlert = false
    var errorMessage: String?
    
    init(storage: StorageService = .shared, notificationService: NotificationService = .shared) {
        self.storage = storage
        self.notificationService = notificationService
        
        // Default to tomorrow at noon
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        var components = Calendar.current.dateComponents([.year, .month, .day], from: tomorrow)
        components.hour = 12
        components.minute = 0
        self.scheduledDate = Calendar.current.date(from: components) ?? tomorrow
    }
    
    // MARK: - Validation
    
    var isValid: Bool {
        // Must have either subject or body (or both)
        let hasContent = !ValidationUtils.isEmpty(subject) || !ValidationUtils.isEmpty(body)
        return hasContent &&
               ValidationUtils.isValidLetterSubject(subject) &&
               ValidationUtils.isValidLetterBody(body) &&
               ValidationUtils.isFutureDate(scheduledDate)
    }
    
    var subjectRemaining: Int {
        return Letter.maxSubjectLength - ValidationUtils.characterCount(subject)
    }
    
    var bodyRemaining: Int {
        return Letter.maxBodyLength - ValidationUtils.characterCount(body)
    }
    
    // MARK: - Scheduling
    
    /// Saves and schedules the letter
    /// - Returns: true if successful
    func saveLetter() async -> Bool {
        print("💌 [ComposeLetterViewModel] saveLetter() called")
        print("💌 [ComposeLetterViewModel] Subject: '\(subject)', Body: '\(body.prefix(50))...', Date: \(scheduledDate)")
        
        do {
            // Request permission if needed (shows system Allow/Don't Allow prompt)
            print("🔔 [ComposeLetterViewModel] Requesting notification permission...")
            let hasPermission = try await notificationService.requestPermission()
            print("🔔 [ComposeLetterViewModel] Permission granted: \(hasPermission)")
            
            if !hasPermission {
                print("⚠️ [ComposeLetterViewModel] Permission denied, showing alert")
                showPermissionAlert = true
                return false
            }
            
            // Create letter
            print("📝 [ComposeLetterViewModel] Creating letter...")
            let letter = try Letter(
                subject: subject.isEmpty ? nil : subject,
                body: body,
                scheduledDate: scheduledDate,
                recurrence: recurrence
            )
            print("📝 [ComposeLetterViewModel] Letter created - ID: \(letter.id)")
            
            // Save to storage (this checks max limit)
            print("💾 [ComposeLetterViewModel] Saving letter to storage...")
            try storage.saveLetter(letter)
            print("✅ [ComposeLetterViewModel] Letter saved to storage")
            
            // Schedule notification
            print("🔔 [ComposeLetterViewModel] Scheduling notification...")
            try notificationService.scheduleLetter(letter)
            print("✅ [ComposeLetterViewModel] Notification scheduled")
            
            print("🎉 [ComposeLetterViewModel] Letter save complete!")
            return true
            
        } catch let error as LetterError {
            print("❌ [ComposeLetterViewModel] LetterError: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
            return false
        } catch {
            print("❌ [ComposeLetterViewModel] Unknown error: \(error)")
            errorMessage = "Failed to save letter"
            return false
        }
    }
}


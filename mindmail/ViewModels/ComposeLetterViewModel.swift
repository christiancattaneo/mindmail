//
//  ComposeLetterViewModel.swift
//  mindmail
//
//  Created by Christian Cattaneo on 10/24/25.
//

import Foundation

/// Manages letter composition state and validation
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
        return ValidationUtils.isValidLetterSubject(subject) &&
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
        do {
            // Check notification permission
            let hasPermission = await notificationService.hasPermission()
            if !hasPermission {
                showPermissionAlert = true
                return false
            }
            
            // Create letter
            let letter = try Letter(
                subject: subject.isEmpty ? nil : subject,
                body: body,
                scheduledDate: scheduledDate,
                recurrence: recurrence
            )
            
            // Save to storage (this checks max limit)
            try storage.saveLetter(letter)
            
            // Schedule notification
            try notificationService.scheduleLetter(letter)
            
            return true
            
        } catch let error as LetterError {
            errorMessage = error.localizedDescription
            return false
        } catch {
            errorMessage = "Failed to save letter"
            return false
        }
    }
    
    /// Requests notification permission
    func requestPermission() async {
        do {
            let granted = try await notificationService.requestPermission()
            if granted {
                showPermissionAlert = false
            }
        } catch {
            errorMessage = "Failed to request permission"
        }
    }
}


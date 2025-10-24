//
//  Letter.swift
//  mindmail
//
//  Created by Christian Cattaneo on 10/24/25.
//

import Foundation

/// Represents a letter to future self with scheduling information
/// Security: Enforces strict limits on content length and scheduling to prevent abuse
struct Letter: Codable, Identifiable, Equatable {
    let id: UUID
    let subject: String?
    let body: String
    let scheduledDate: Date
    let recurrence: RecurrencePattern
    let createdAt: Date
    let isDelivered: Bool
    let deliveredAt: Date?
    
    /// Maximum length for letter subject (focused and concise)
    static let maxSubjectLength = 50
    
    /// Minimum length for letter subject (if provided)
    static let minSubjectLength = 1
    
    /// Maximum length for letter body (heartfelt but focused message)
    static let maxBodyLength = 500
    
    /// Minimum length for letter body (message is required)
    static let minBodyLength = 0
    
    /// Maximum number of letters that can be scheduled (SAFETY LIMIT - prevent abuse)
    static let maxScheduledLetters = 100
    
    /// Minimum time in the future for scheduling (prevent immediate loops)
    static let minScheduleDelay: TimeInterval = 60 // 1 minute
    
    /// Creates a new letter with validated inputs
    /// - Parameters:
    ///   - subject: Optional subject line for the letter
    ///   - body: The letter content
    ///   - scheduledDate: When to deliver the letter
    ///   - recurrence: How often to deliver (once, daily, weekly)
    /// - Throws: ValidationError if any input fails validation
    init(subject: String?, body: String, scheduledDate: Date, recurrence: RecurrencePattern) throws {
        // Validate subject if provided (must have at least 1 char if not empty)
        let validatedSubject: String?
        if let subject = subject {
            let trimmed = subject.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty {
                guard trimmed.count >= Self.minSubjectLength else {
                    throw ValidationError.emptyText
                }
                guard trimmed.count <= Self.maxSubjectLength else {
                    throw ValidationError.textTooLong(maxLength: Self.maxSubjectLength)
                }
                validatedSubject = Self.sanitizeText(trimmed)
            } else {
                validatedSubject = nil
            }
        } else {
            validatedSubject = nil
        }
        
        // Validate body (can be empty - minimum 0 characters)
        let trimmedBody = body.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedBody.count <= Self.maxBodyLength else {
            throw ValidationError.textTooLong(maxLength: Self.maxBodyLength)
        }
        
        // Allow empty body (user might just want to schedule a reminder)
        let finalBody = trimmedBody.isEmpty ? "" : Self.sanitizeText(trimmedBody)
        
        // Validate scheduled date is in the future (prevent self-triggering loops)
        guard scheduledDate.timeIntervalSinceNow >= Self.minScheduleDelay else {
            throw LetterError.scheduledDateMustBeInFuture
        }
        
        self.id = UUID()
        self.subject = validatedSubject
        self.body = finalBody
        self.scheduledDate = scheduledDate
        self.recurrence = recurrence
        self.createdAt = Date()
        self.isDelivered = false
        self.deliveredAt = nil
    }
    
    /// For Codable and internal use - assumes data is already validated
    init(id: UUID, subject: String?, body: String, scheduledDate: Date, recurrence: RecurrencePattern, createdAt: Date, isDelivered: Bool, deliveredAt: Date?) {
        self.id = id
        self.subject = subject
        self.body = body
        self.scheduledDate = scheduledDate
        self.recurrence = recurrence
        self.createdAt = createdAt
        self.isDelivered = isDelivered
        self.deliveredAt = deliveredAt
    }
    
    /// Creates a copy marked as delivered
    func markAsDelivered() -> Letter {
        Letter(
            id: self.id,
            subject: self.subject,
            body: self.body,
            scheduledDate: self.scheduledDate,
            recurrence: self.recurrence,
            createdAt: self.createdAt,
            isDelivered: true,
            deliveredAt: Date()
        )
    }
    
    /// Sanitizes text by removing control characters but preserving newlines
    private static func sanitizeText(_ text: String) -> String {
        return text.components(separatedBy: .controlCharacters.subtracting(.newlines)).joined()
    }
}

/// Letter-specific errors
enum LetterError: LocalizedError {
    case scheduledDateMustBeInFuture
    case maxLettersExceeded
    case schedulingFailed
    
    var errorDescription: String? {
        switch self {
        case .scheduledDateMustBeInFuture:
            return "Letters must be scheduled at least 1 minute in the future"
        case .maxLettersExceeded:
            return "Maximum of \(Letter.maxScheduledLetters) scheduled letters reached"
        case .schedulingFailed:
            return "Failed to schedule letter notification"
        }
    }
}


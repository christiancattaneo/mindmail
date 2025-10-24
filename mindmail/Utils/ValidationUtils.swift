//
//  ValidationUtils.swift
//  mindmail
//
//  Created by Christian Cattaneo on 10/24/25.
//

import Foundation

/// Centralized input validation and sanitization utilities
/// Security: All text inputs must be validated and sanitized to prevent injection attacks
enum ValidationUtils {
    
    // MARK: - Text Validation
    
    /// Validates text against length constraints
    /// - Parameters:
    ///   - text: The text to validate
    ///   - minLength: Minimum length (default 1)
    ///   - maxLength: Maximum length
    /// - Returns: true if valid
    static func isValidLength(_ text: String, minLength: Int = 1, maxLength: Int) -> Bool {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.count >= minLength && trimmed.count <= maxLength
    }
    
    /// Checks if text is empty after trimming whitespace
    /// - Parameter text: Text to check
    /// - Returns: true if empty
    static func isEmpty(_ text: String) -> Bool {
        return text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    /// Gets the character count for display (after trimming)
    /// - Parameter text: Text to count
    /// - Returns: Character count
    static func characterCount(_ text: String) -> Int {
        return text.trimmingCharacters(in: .whitespacesAndNewlines).count
    }
    
    // MARK: - Text Sanitization
    
    /// Sanitizes text by removing control characters but preserving newlines
    /// Security: Prevents injection of malicious control characters
    /// - Parameter text: Text to sanitize
    /// - Returns: Sanitized text
    static func sanitizeText(_ text: String) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Remove control characters except newlines
        let sanitized = trimmed.components(separatedBy: .controlCharacters.subtracting(.newlines)).joined()
        
        // Normalize whitespace (collapse multiple spaces)
        let normalized = sanitized.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        
        return normalized
    }
    
    /// Sanitizes text for name input (more restrictive)
    /// - Parameter text: Text to sanitize
    /// - Returns: Sanitized name
    static func sanitizeName(_ text: String) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Only allow letters, spaces, hyphens, and apostrophes
        let allowedCharacters = CharacterSet.letters
            .union(.whitespaces)
            .union(CharacterSet(charactersIn: "-'"))
        
        let filtered = String(trimmed.unicodeScalars.filter { allowedCharacters.contains($0) })
        
        // Normalize whitespace
        return filtered.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
    }
    
    /// Strips all HTML tags from text (defense in depth)
    /// Security: Prevents XSS-style attacks even though we're local-only
    /// - Parameter text: Text to strip
    /// - Returns: Text without HTML
    static func stripHTML(_ text: String) -> String {
        return text.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
    }
    
    // MARK: - Name Validation
    
    /// Validates a name meets requirements
    /// - Parameter name: Name to validate
    /// - Returns: true if valid
    static func isValidName(_ name: String) -> Bool {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check length
        guard trimmed.count >= User.minNameLength && trimmed.count <= User.maxNameLength else {
            return false
        }
        
        // Check character set
        let allowedCharacters = CharacterSet.letters
            .union(.whitespaces)
            .union(CharacterSet(charactersIn: "-'"))
        
        return trimmed.unicodeScalars.allSatisfy { allowedCharacters.contains($0) }
    }
    
    // MARK: - Journal Entry Validation
    
    /// Validates journal entry text field
    /// - Parameter text: Text to validate
    /// - Returns: true if valid
    static func isValidJournalText(_ text: String) -> Bool {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmed.isEmpty && trimmed.count <= JournalEntry.maxTextLength
    }
    
    /// Gets remaining character count for journal fields
    /// - Parameter text: Current text
    /// - Returns: Characters remaining
    static func remainingCharacters(_ text: String, maxLength: Int) -> Int {
        let count = characterCount(text)
        return max(0, maxLength - count)
    }
    
    // MARK: - Letter Validation
    
    /// Validates letter subject
    /// - Parameter subject: Subject to validate
    /// - Returns: true if valid (empty is valid since optional)
    static func isValidLetterSubject(_ subject: String) -> Bool {
        if isEmpty(subject) {
            return true // Optional field
        }
        return characterCount(subject) <= Letter.maxSubjectLength
    }
    
    /// Validates letter body (can be empty)
    /// - Parameter body: Body to validate
    /// - Returns: true if valid
    static func isValidLetterBody(_ body: String) -> Bool {
        let trimmed = body.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.count <= Letter.maxBodyLength
    }
    
    // MARK: - Date Validation
    
    /// Validates that a date is in the future
    /// - Parameter date: Date to validate
    /// - Returns: true if date is in the future
    static func isFutureDate(_ date: Date) -> Bool {
        return date.timeIntervalSinceNow >= Letter.minScheduleDelay
    }
    
    /// Validates that a date is valid for journal entry (not in future)
    /// - Parameter date: Date to validate
    /// - Returns: true if date is today or in the past
    static func isValidJournalDate(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let entryDate = calendar.startOfDay(for: date)
        return entryDate <= today
    }
}


//
//  JournalEntry.swift
//  mindmail
//
//  Created by Christian Cattaneo on 10/24/25.
//

import Foundation

/// Represents a daily journal entry with all reflections
/// Security: All text fields have strict length limits and validation
struct JournalEntry: Codable, Identifiable, Equatable {
    let id: UUID
    let date: Date
    let mood: MoodType
    let struggle: String
    let gratitude: String
    let memory: String
    let lookingForward: String
    let createdAt: Date
    let modifiedAt: Date
    
    /// Maximum character limit for text fields (per PRD)
    static let maxTextLength = 140
    
    /// Creates a new journal entry with validated inputs
    /// - Parameters:
    ///   - date: The date this entry is for (time component will be normalized to midnight)
    ///   - mood: The user's overall mood for the day
    ///   - struggle: One thing that was hard today
    ///   - gratitude: Something the user is grateful for
    ///   - memory: A moment to remember
    ///   - lookingForward: Something the user is excited about
    /// - Throws: ValidationError if any input fails validation
    init(date: Date, mood: MoodType, struggle: String, gratitude: String, memory: String, lookingForward: String) throws {
        // Validate and sanitize all text inputs
        let validatedStruggle = try Self.validateText(struggle)
        let validatedGratitude = try Self.validateText(gratitude)
        let validatedMemory = try Self.validateText(memory)
        let validatedLookingForward = try Self.validateText(lookingForward)
        
        self.id = UUID()
        self.date = Calendar.current.startOfDay(for: date)
        self.mood = mood
        self.struggle = validatedStruggle
        self.gratitude = validatedGratitude
        self.memory = validatedMemory
        self.lookingForward = validatedLookingForward
        self.createdAt = Date()
        self.modifiedAt = Date()
    }
    
    /// For updating existing entries
    init(id: UUID, date: Date, mood: MoodType, struggle: String, gratitude: String, memory: String, lookingForward: String, createdAt: Date) throws {
        let validatedStruggle = try Self.validateText(struggle)
        let validatedGratitude = try Self.validateText(gratitude)
        let validatedMemory = try Self.validateText(memory)
        let validatedLookingForward = try Self.validateText(lookingForward)
        
        self.id = id
        self.date = Calendar.current.startOfDay(for: date)
        self.mood = mood
        self.struggle = validatedStruggle
        self.gratitude = validatedGratitude
        self.memory = validatedMemory
        self.lookingForward = validatedLookingForward
        self.createdAt = createdAt
        self.modifiedAt = Date()
    }
    
    /// For Codable - assumes data is already validated
    init(id: UUID, date: Date, mood: MoodType, struggle: String, gratitude: String, memory: String, lookingForward: String, createdAt: Date, modifiedAt: Date) {
        self.id = id
        self.date = date
        self.mood = mood
        self.struggle = struggle
        self.gratitude = gratitude
        self.memory = memory
        self.lookingForward = lookingForward
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
    }
    
    /// Validates text input with length and character checks
    /// - Parameter text: The text to validate
    /// - Returns: Trimmed and validated text
    /// - Throws: ValidationError if text fails validation
    private static func validateText(_ text: String) throws -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmed.isEmpty else {
            throw ValidationError.emptyText
        }
        
        guard trimmed.count <= maxTextLength else {
            throw ValidationError.textTooLong(maxLength: maxTextLength)
        }
        
        // Sanitize: remove control characters but preserve newlines
        let sanitized = trimmed.components(separatedBy: .controlCharacters.subtracting(.newlines)).joined()
        
        return sanitized
    }
    
    /// Returns a normalized date key for storage/lookup (YYYY-MM-DD)
    var dateKey: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}


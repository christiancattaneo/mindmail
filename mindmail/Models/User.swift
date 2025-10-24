//
//  User.swift
//  mindmail
//
//  Created by Christian Cattaneo on 10/24/25.
//

import Foundation

/// Represents the app user with validated data
/// Security: Enforces input validation on all fields
struct User: Codable, Equatable {
    let name: String
    let createdAt: Date
    
    /// Maximum allowed length for user name (defense against abuse)
    static let maxNameLength = 50
    
    /// Minimum allowed length for user name
    static let minNameLength = 1
    
    /// Creates a new user with validated input
    /// - Parameter name: User's first name
    /// - Throws: ValidationError if name fails validation
    init(name: String) throws {
        // Trim whitespace
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Validate length
        guard !trimmedName.isEmpty else {
            throw ValidationError.emptyName
        }
        
        guard trimmedName.count >= User.minNameLength else {
            throw ValidationError.nameTooShort
        }
        
        guard trimmedName.count <= User.maxNameLength else {
            throw ValidationError.nameTooLong
        }
        
        // Validate character set (letters, spaces, basic punctuation only)
        let allowedCharacters = CharacterSet.letters
            .union(.whitespaces)
            .union(CharacterSet(charactersIn: "-'"))
        
        guard trimmedName.unicodeScalars.allSatisfy({ allowedCharacters.contains($0) }) else {
            throw ValidationError.invalidCharacters
        }
        
        self.name = trimmedName
        self.createdAt = Date()
    }
    
    /// For Codable compatibility - assumes data is already validated
    init(name: String, createdAt: Date) {
        self.name = name
        self.createdAt = createdAt
    }
}

/// Validation errors for User model
enum ValidationError: LocalizedError {
    case emptyName
    case nameTooShort
    case nameTooLong
    case invalidCharacters
    case textTooLong(maxLength: Int)
    case emptyText
    
    var errorDescription: String? {
        switch self {
        case .emptyName:
            return "Name cannot be empty"
        case .nameTooShort:
            return "Name is too short"
        case .nameTooLong:
            return "Name is too long (max \(User.maxNameLength) characters)"
        case .invalidCharacters:
            return "Name contains invalid characters"
        case .textTooLong(let maxLength):
            return "Text is too long (max \(maxLength) characters)"
        case .emptyText:
            return "Text cannot be empty"
        }
    }
}


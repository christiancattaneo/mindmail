//
//  StorageService.swift
//  mindmail
//
//  Created by Christian Cattaneo on 10/24/25.
//

import Foundation

/// Secure local storage service for all app data
/// Security: Uses UserDefaults with data integrity checks and error handling
/// All data is stored locally on device - no cloud sync
class StorageService {
    
    // MARK: - Singleton
    static let shared = StorageService()
    
    // MARK: - Storage Keys
    private enum StorageKey: String {
        case user = "com.mindmail.user"
        case journalEntries = "com.mindmail.journal_entries"
        case letters = "com.mindmail.letters"
        case hasCompletedOnboarding = "com.mindmail.onboarding_completed"
    }
    
    // MARK: - Private Properties
    private let userDefaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    // MARK: - Initialization
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        
        // Configure encoder/decoder with ISO8601 date formatting
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }
    
    // MARK: - User Management
    
    /// Saves the user profile
    /// - Parameter user: User object to save
    /// - Throws: StorageError if save fails
    func saveUser(_ user: User) throws {
        do {
            let data = try encoder.encode(user)
            userDefaults.set(data, forKey: StorageKey.user.rawValue)
            userDefaults.synchronize()
        } catch {
            throw StorageError.saveFailed(reason: "Failed to encode user data")
        }
    }
    
    /// Loads the user profile
    /// - Returns: User object if exists, nil otherwise
    /// - Throws: StorageError if data is corrupted
    func loadUser() throws -> User? {
        guard let data = userDefaults.data(forKey: StorageKey.user.rawValue) else {
            return nil
        }
        
        do {
            return try decoder.decode(User.self, from: data)
        } catch {
            throw StorageError.loadFailed(reason: "User data corrupted")
        }
    }
    
    // MARK: - Onboarding Status
    
    /// Marks onboarding as completed
    func completeOnboarding() {
        userDefaults.set(true, forKey: StorageKey.hasCompletedOnboarding.rawValue)
        userDefaults.synchronize()
    }
    
    /// Checks if user has completed onboarding
    /// - Returns: true if onboarding is complete
    func hasCompletedOnboarding() -> Bool {
        return userDefaults.bool(forKey: StorageKey.hasCompletedOnboarding.rawValue)
    }
    
    // MARK: - Journal Entry Management
    
    /// Saves a journal entry (creates new or updates existing)
    /// - Parameter entry: JournalEntry to save
    /// - Throws: StorageError if save fails
    func saveJournalEntry(_ entry: JournalEntry) throws {
        var entries = try loadAllJournalEntries()
        
        // Remove existing entry for this date if it exists
        entries.removeAll { $0.dateKey == entry.dateKey }
        
        // Add new/updated entry
        entries.append(entry)
        
        // Save back to storage
        try saveAllJournalEntries(entries)
    }
    
    /// Loads journal entry for a specific date
    /// - Parameter date: Date to load entry for
    /// - Returns: JournalEntry if exists for that date
    func loadJournalEntry(for date: Date) throws -> JournalEntry? {
        let entries = try loadAllJournalEntries()
        let normalizedDate = Calendar.current.startOfDay(for: date)
        return entries.first { Calendar.current.isDate($0.date, inSameDayAs: normalizedDate) }
    }
    
    /// Loads all journal entries
    /// - Returns: Array of all journal entries
    /// - Throws: StorageError if load fails
    func loadAllJournalEntries() throws -> [JournalEntry] {
        guard let data = userDefaults.data(forKey: StorageKey.journalEntries.rawValue) else {
            return []
        }
        
        do {
            return try decoder.decode([JournalEntry].self, from: data)
        } catch {
            throw StorageError.loadFailed(reason: "Journal entries data corrupted")
        }
    }
    
    /// Saves all journal entries (overwrites existing)
    /// - Parameter entries: Array of entries to save
    /// - Throws: StorageError if save fails
    private func saveAllJournalEntries(_ entries: [JournalEntry]) throws {
        do {
            let data = try encoder.encode(entries)
            userDefaults.set(data, forKey: StorageKey.journalEntries.rawValue)
            userDefaults.synchronize()
        } catch {
            throw StorageError.saveFailed(reason: "Failed to encode journal entries")
        }
    }
    
    /// Deletes a journal entry
    /// - Parameter entryId: UUID of entry to delete
    /// - Throws: StorageError if delete fails
    func deleteJournalEntry(_ entryId: UUID) throws {
        var entries = try loadAllJournalEntries()
        entries.removeAll { $0.id == entryId }
        try saveAllJournalEntries(entries)
    }
    
    // MARK: - Letter Management
    
    /// Saves a letter (creates new or updates existing)
    /// - Parameter letter: Letter to save
    /// - Throws: StorageError if save fails or max limit exceeded
    func saveLetter(_ letter: Letter) throws {
        var letters = try loadAllLetters()
        
        // Check max letter limit (SAFETY: prevent abuse)
        if !letters.contains(where: { $0.id == letter.id }) {
            // New letter - check limit
            let scheduledCount = letters.filter { !$0.isDelivered }.count
            guard scheduledCount < Letter.maxScheduledLetters else {
                throw LetterError.maxLettersExceeded
            }
        }
        
        // Remove existing letter if updating
        letters.removeAll { $0.id == letter.id }
        
        // Add letter
        letters.append(letter)
        
        // Save back to storage
        try saveAllLetters(letters)
    }
    
    /// Loads all letters
    /// - Returns: Array of all letters
    /// - Throws: StorageError if load fails
    func loadAllLetters() throws -> [Letter] {
        guard let data = userDefaults.data(forKey: StorageKey.letters.rawValue) else {
            return []
        }
        
        do {
            return try decoder.decode([Letter].self, from: data)
        } catch {
            throw StorageError.loadFailed(reason: "Letters data corrupted")
        }
    }
    
    /// Loads a specific letter by ID
    /// - Parameter id: UUID of the letter
    /// - Returns: Letter if found
    func loadLetter(_ id: UUID) throws -> Letter? {
        let letters = try loadAllLetters()
        return letters.first { $0.id == id }
    }
    
    /// Loads all scheduled (undelivered) letters
    /// - Returns: Array of scheduled letters
    func loadScheduledLetters() throws -> [Letter] {
        let letters = try loadAllLetters()
        return letters.filter { !$0.isDelivered }
    }
    
    /// Loads all delivered letters
    /// - Returns: Array of delivered letters
    func loadDeliveredLetters() throws -> [Letter] {
        let letters = try loadAllLetters()
        return letters.filter { $0.isDelivered }
    }
    
    /// Saves all letters (overwrites existing)
    /// - Parameter letters: Array of letters to save
    /// - Throws: StorageError if save fails
    private func saveAllLetters(_ letters: [Letter]) throws {
        do {
            let data = try encoder.encode(letters)
            userDefaults.set(data, forKey: StorageKey.letters.rawValue)
            userDefaults.synchronize()
        } catch {
            throw StorageError.saveFailed(reason: "Failed to encode letters")
        }
    }
    
    /// Deletes a letter
    /// - Parameter letterId: UUID of letter to delete
    /// - Throws: StorageError if delete fails
    func deleteLetter(_ letterId: UUID) throws {
        var letters = try loadAllLetters()
        letters.removeAll { $0.id == letterId }
        try saveAllLetters(letters)
    }
    
    /// Marks a letter as delivered
    /// - Parameter letterId: UUID of letter to mark as delivered
    /// - Throws: StorageError if update fails
    func markLetterAsDelivered(_ letterId: UUID) throws {
        var letters = try loadAllLetters()
        
        guard let index = letters.firstIndex(where: { $0.id == letterId }) else {
            throw StorageError.notFound(item: "Letter")
        }
        
        letters[index] = letters[index].markAsDelivered()
        try saveAllLetters(letters)
    }
    
    // MARK: - Data Management
    
    /// Clears all app data (for testing/reset)
    /// WARNING: This is destructive and cannot be undone
    func clearAllData() {
        userDefaults.removeObject(forKey: StorageKey.user.rawValue)
        userDefaults.removeObject(forKey: StorageKey.journalEntries.rawValue)
        userDefaults.removeObject(forKey: StorageKey.letters.rawValue)
        userDefaults.removeObject(forKey: StorageKey.hasCompletedOnboarding.rawValue)
        userDefaults.synchronize()
    }
}

// MARK: - Storage Errors

/// Errors that can occur during storage operations
enum StorageError: LocalizedError {
    case saveFailed(reason: String)
    case loadFailed(reason: String)
    case notFound(item: String)
    case dataCorrupted
    
    var errorDescription: String? {
        switch self {
        case .saveFailed(let reason):
            return "Save failed: \(reason)"
        case .loadFailed(let reason):
            return "Load failed: \(reason)"
        case .notFound(let item):
            return "\(item) not found"
        case .dataCorrupted:
            return "Data corrupted"
        }
    }
}


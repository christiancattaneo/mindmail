//
//  StorageServiceTests.swift
//  mindmailTests
//
//  Created by Christian Cattaneo on 10/24/25.
//

import Testing
import Foundation
@testable import mindmail

struct StorageServiceTests {
    
    // MARK: - Setup & Teardown
    
    func createTestStorage() -> StorageService {
        // Use a test-specific UserDefaults to avoid polluting real data
        let testDefaults = UserDefaults(suiteName: "com.mindmail.tests")!
        testDefaults.removePersistentDomain(forName: "com.mindmail.tests")
        return StorageService(userDefaults: testDefaults)
    }
    
    // MARK: - User Storage Tests
    
    @Test func testSaveAndLoadUser() async throws {
        let storage = createTestStorage()
        let user = try User(name: "TestUser")
        
        try storage.saveUser(user)
        let loaded = try storage.loadUser()
        
        #expect(loaded != nil)
        #expect(loaded?.name == "TestUser")
    }
    
    @Test func testLoadUserWhenNoneExists() async throws {
        let storage = createTestStorage()
        let loaded = try storage.loadUser()
        
        #expect(loaded == nil)
    }
    
    @Test func testUpdateUser() async throws {
        let storage = createTestStorage()
        let user1 = try User(name: "First")
        let user2 = try User(name: "Second")
        
        try storage.saveUser(user1)
        try storage.saveUser(user2)
        
        let loaded = try storage.loadUser()
        #expect(loaded?.name == "Second")
    }
    
    // MARK: - Onboarding Status Tests
    
    @Test func testOnboardingNotCompletedByDefault() async throws {
        let storage = createTestStorage()
        #expect(storage.hasCompletedOnboarding() == false)
    }
    
    @Test func testCompleteOnboarding() async throws {
        let storage = createTestStorage()
        storage.completeOnboarding()
        #expect(storage.hasCompletedOnboarding() == true)
    }
    
    // MARK: - Journal Entry Storage Tests
    
    @Test func testSaveAndLoadJournalEntry() async throws {
        let storage = createTestStorage()
        let entry = try JournalEntry(
            date: Date(),
            mood: .awesome,
            struggle: "Test struggle",
            gratitude: "Test gratitude",
            memory: "Test memory",
            lookingForward: "Test future"
        )
        
        try storage.saveJournalEntry(entry)
        let loaded = try storage.loadJournalEntry(for: Date())
        
        #expect(loaded != nil)
        #expect(loaded?.mood == .awesome)
        #expect(loaded?.struggle == "Test struggle")
    }
    
    @Test func testLoadAllJournalEntries() async throws {
        let storage = createTestStorage()
        
        let entry1 = try JournalEntry(
            date: Date(),
            mood: .awesome,
            struggle: "Day 1",
            gratitude: "Day 1",
            memory: "Day 1",
            lookingForward: "Day 1"
        )
        
        let yesterday = Date().addingTimeInterval(-86400)
        let entry2 = try JournalEntry(
            date: yesterday,
            mood: .justFine,
            struggle: "Day 2",
            gratitude: "Day 2",
            memory: "Day 2",
            lookingForward: "Day 2"
        )
        
        try storage.saveJournalEntry(entry1)
        try storage.saveJournalEntry(entry2)
        
        let all = try storage.loadAllJournalEntries()
        #expect(all.count == 2)
    }
    
    @Test func testUpdateJournalEntry() async throws {
        let storage = createTestStorage()
        let date = Date()
        
        let entry1 = try JournalEntry(
            date: date,
            mood: .awesome,
            struggle: "Original",
            gratitude: "Original",
            memory: "Original",
            lookingForward: "Original"
        )
        
        try storage.saveJournalEntry(entry1)
        
        let entry2 = try JournalEntry(
            date: date,
            mood: .stressful,
            struggle: "Updated",
            gratitude: "Updated",
            memory: "Updated",
            lookingForward: "Updated"
        )
        
        try storage.saveJournalEntry(entry2)
        
        let loaded = try storage.loadJournalEntry(for: date)
        #expect(loaded?.struggle == "Updated")
        #expect(loaded?.mood == .stressful)
        
        let all = try storage.loadAllJournalEntries()
        #expect(all.count == 1) // Should replace, not add
    }
    
    @Test func testDeleteJournalEntry() async throws {
        let storage = createTestStorage()
        
        let entry = try JournalEntry(
            date: Date(),
            mood: .awesome,
            struggle: "Test",
            gratitude: "Test",
            memory: "Test",
            lookingForward: "Test"
        )
        
        try storage.saveJournalEntry(entry)
        var all = try storage.loadAllJournalEntries()
        #expect(all.count == 1)
        
        try storage.deleteJournalEntry(entry.id)
        all = try storage.loadAllJournalEntries()
        #expect(all.count == 0)
    }
    
    // MARK: - Letter Storage Tests
    
    @Test func testSaveAndLoadLetter() async throws {
        let storage = createTestStorage()
        let futureDate = Date().addingTimeInterval(3600)
        
        let letter = try Letter(
            subject: "Test Subject",
            body: "Test Body",
            scheduledDate: futureDate,
            recurrence: .once
        )
        
        try storage.saveLetter(letter)
        let loaded = try storage.loadLetter(letter.id)
        
        #expect(loaded != nil)
        #expect(loaded?.subject == "Test Subject")
        #expect(loaded?.body == "Test Body")
    }
    
    @Test func testLoadAllLetters() async throws {
        let storage = createTestStorage()
        let futureDate = Date().addingTimeInterval(3600)
        
        let letter1 = try Letter(
            subject: "Letter 1",
            body: "Body 1",
            scheduledDate: futureDate,
            recurrence: .once
        )
        
        let letter2 = try Letter(
            subject: "Letter 2",
            body: "Body 2",
            scheduledDate: futureDate.addingTimeInterval(7200),
            recurrence: .daily
        )
        
        try storage.saveLetter(letter1)
        try storage.saveLetter(letter2)
        
        let all = try storage.loadAllLetters()
        #expect(all.count == 2)
    }
    
    @Test func testMaxLetterLimitEnforced() async throws {
        let storage = createTestStorage()
        let futureDate = Date().addingTimeInterval(3600)
        
        // Create exactly 100 letters (the max)
        for i in 1...100 {
            let letter = try Letter(
                subject: "Letter \(i)",
                body: "Body \(i)",
                scheduledDate: futureDate.addingTimeInterval(Double(i * 60)),
                recurrence: .once
            )
            try storage.saveLetter(letter)
        }
        
        // Try to add one more - should throw
        let extraLetter = try Letter(
            subject: "Extra",
            body: "Should fail",
            scheduledDate: futureDate.addingTimeInterval(10000),
            recurrence: .once
        )
        
        #expect(throws: LetterError.self) {
            try storage.saveLetter(extraLetter)
        }
    }
    
    @Test func testLoadScheduledLetters() async throws {
        let storage = createTestStorage()
        let futureDate = Date().addingTimeInterval(3600)
        
        let scheduled = try Letter(
            subject: "Scheduled",
            body: "Not delivered",
            scheduledDate: futureDate,
            recurrence: .once
        )
        
        try storage.saveLetter(scheduled)
        try storage.markLetterAsDelivered(scheduled.id)
        
        let scheduledLetters = try storage.loadScheduledLetters()
        #expect(scheduledLetters.count == 0)
        
        let deliveredLetters = try storage.loadDeliveredLetters()
        #expect(deliveredLetters.count == 1)
    }
    
    @Test func testMarkLetterAsDelivered() async throws {
        let storage = createTestStorage()
        let futureDate = Date().addingTimeInterval(3600)
        
        let letter = try Letter(
            subject: "Test",
            body: "Body",
            scheduledDate: futureDate,
            recurrence: .once
        )
        
        try storage.saveLetter(letter)
        
        var loaded = try storage.loadLetter(letter.id)
        #expect(loaded?.isDelivered == false)
        #expect(loaded?.deliveredAt == nil)
        
        try storage.markLetterAsDelivered(letter.id)
        
        loaded = try storage.loadLetter(letter.id)
        #expect(loaded?.isDelivered == true)
        #expect(loaded?.deliveredAt != nil)
    }
    
    @Test func testDeleteLetter() async throws {
        let storage = createTestStorage()
        let futureDate = Date().addingTimeInterval(3600)
        
        let letter = try Letter(
            subject: "Test",
            body: "Body",
            scheduledDate: futureDate,
            recurrence: .once
        )
        
        try storage.saveLetter(letter)
        var all = try storage.loadAllLetters()
        #expect(all.count == 1)
        
        try storage.deleteLetter(letter.id)
        all = try storage.loadAllLetters()
        #expect(all.count == 0)
    }
    
    // MARK: - Data Integrity Tests
    
    @Test func testClearAllData() async throws {
        let storage = createTestStorage()
        
        // Add some data
        let user = try User(name: "Test")
        try storage.saveUser(user)
        storage.completeOnboarding()
        
        let entry = try JournalEntry(
            date: Date(),
            mood: .awesome,
            struggle: "Test",
            gratitude: "Test",
            memory: "Test",
            lookingForward: "Test"
        )
        try storage.saveJournalEntry(entry)
        
        let letter = try Letter(
            subject: "Test",
            body: "Body",
            scheduledDate: Date().addingTimeInterval(3600),
            recurrence: .once
        )
        try storage.saveLetter(letter)
        
        // Clear everything
        storage.clearAllData()
        
        // Verify all cleared
        let loadedUser = try storage.loadUser()
        #expect(loadedUser == nil)
        #expect(storage.hasCompletedOnboarding() == false)
        
        let entries = try storage.loadAllJournalEntries()
        #expect(entries.isEmpty)
        
        let letters = try storage.loadAllLetters()
        #expect(letters.isEmpty)
    }
}


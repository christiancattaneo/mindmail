//
//  NotificationServiceTests.swift
//  mindmailTests
//
//  Created by Christian Cattaneo on 10/24/25.
//

import Testing
import Foundation
@testable import mindmail

struct NotificationServiceTests {
    
    func createTestStorage() -> StorageService {
        let testDefaults = UserDefaults(suiteName: "com.mindmail.notification.tests")!
        testDefaults.removePersistentDomain(forName: "com.mindmail.notification.tests")
        return StorageService(userDefaults: testDefaults)
    }
    
    // MARK: - Letter Scheduling Tests
    
    @Test func testScheduleValidLetter() async throws {
        let storage = createTestStorage()
        let futureDate = Date().addingTimeInterval(3600) // 1 hour from now
        
        let letter = try Letter(
            subject: "Test Letter",
            body: "This is a test letter to my future self.",
            scheduledDate: futureDate,
            recurrence: .once
        )
        
        // Save letter
        try storage.saveLetter(letter)
        
        // Verify it was saved
        let saved = try storage.loadLetter(letter.id)
        #expect(saved != nil)
        #expect(saved?.subject == "Test Letter")
    }
    
    @Test func testScheduleRecurringLetter() async throws {
        let storage = createTestStorage()
        let futureDate = Date().addingTimeInterval(3600)
        
        let letter = try Letter(
            subject: "Daily Reminder",
            body: "Remember to stay positive!",
            scheduledDate: futureDate,
            recurrence: .daily
        )
        
        try storage.saveLetter(letter)
        
        let saved = try storage.loadLetter(letter.id)
        #expect(saved?.recurrence == .daily)
    }
    
    @Test func testMaxLetterLimitEnforced() async throws {
        let storage = createTestStorage()
        let futureDate = Date().addingTimeInterval(3600)
        
        // Create exactly 100 letters
        for i in 1...100 {
            let letter = try Letter(
                subject: "Letter \(i)",
                body: "Body \(i)",
                scheduledDate: futureDate.addingTimeInterval(Double(i * 60)),
                recurrence: .once
            )
            try storage.saveLetter(letter)
        }
        
        // Try to add 101st letter - should throw
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
    
    @Test func testMinimumDelayEnforced() async throws {
        let tooSoon = Date().addingTimeInterval(30) // 30 seconds (less than 60)
        
        #expect(throws: LetterError.self) {
            _ = try Letter(
                subject: "Too Soon",
                body: "Should fail",
                scheduledDate: tooSoon,
                recurrence: .once
            )
        }
    }
    
    @Test func testPastDateRejected() async throws {
        let pastDate = Date().addingTimeInterval(-3600) // 1 hour ago
        
        #expect(throws: LetterError.self) {
            _ = try Letter(
                subject: "Past",
                body: "Should fail",
                scheduledDate: pastDate,
                recurrence: .once
            )
        }
    }
    
    // MARK: - Letter Management Tests
    
    @Test func testLoadScheduledLetters() async throws {
        let storage = createTestStorage()
        let futureDate = Date().addingTimeInterval(3600)
        
        // Add scheduled letter
        let letter = try Letter(
            subject: "Scheduled",
            body: "Future letter",
            scheduledDate: futureDate,
            recurrence: .once
        )
        try storage.saveLetter(letter)
        
        let scheduled = try storage.loadScheduledLetters()
        #expect(scheduled.count == 1)
        #expect(scheduled.first?.isDelivered == false)
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
        
        // Mark as delivered
        try storage.markLetterAsDelivered(letter.id)
        
        let delivered = try storage.loadLetter(letter.id)
        #expect(delivered?.isDelivered == true)
        #expect(delivered?.deliveredAt != nil)
        
        // Should now be in delivered list
        let deliveredLetters = try storage.loadDeliveredLetters()
        #expect(deliveredLetters.count == 1)
        
        let scheduledLetters = try storage.loadScheduledLetters()
        #expect(scheduledLetters.count == 0)
    }
    
    @Test func testDeleteLetter() async throws {
        let storage = createTestStorage()
        let futureDate = Date().addingTimeInterval(3600)
        
        let letter = try Letter(
            subject: "To Delete",
            body: "Will be removed",
            scheduledDate: futureDate,
            recurrence: .once
        )
        try storage.saveLetter(letter)
        
        var letters = try storage.loadAllLetters()
        #expect(letters.count == 1)
        
        try storage.deleteLetter(letter.id)
        
        letters = try storage.loadAllLetters()
        #expect(letters.count == 0)
    }
    
    // MARK: - Recurrence Pattern Tests
    
    @Test func testRecurrencePatterns() async throws {
        #expect(RecurrencePattern.once.label == "One Time")
        #expect(RecurrencePattern.daily.label == "Daily Reminder")
        
        #expect(RecurrencePattern.once.calendarComponent == nil)
        #expect(RecurrencePattern.daily.calendarComponent == .day)
    }
    
    // MARK: - Safety Limit Tests
    
    @Test func testNoSelfTriggeringLoops() async throws {
        // Verify minimum delay prevents immediate re-triggering
        let minDelay = Letter.minScheduleDelay
        #expect(minDelay >= 60) // At least 1 minute
        
        let validDate = Date().addingTimeInterval(minDelay + 1)
        let letter = try Letter(
            subject: "Safe",
            body: "Has proper delay",
            scheduledDate: validDate,
            recurrence: .once
        )
        
        #expect(letter.scheduledDate.timeIntervalSinceNow >= minDelay)
    }
    
    @Test func testMaxLettersLimit() async throws {
        #expect(Letter.maxScheduledLetters == 100)
    }
    
    // MARK: - Letter Update Tests
    
    @Test func testUpdateExistingLetter() async throws {
        let storage = createTestStorage()
        let futureDate = Date().addingTimeInterval(3600)
        
        let letter = try Letter(
            subject: "Original",
            body: "Original body",
            scheduledDate: futureDate,
            recurrence: .once
        )
        try storage.saveLetter(letter)
        
        // Update with same ID
        let updated = Letter(
            id: letter.id,
            subject: "Updated",
            body: "Updated body",
            scheduledDate: futureDate,
            recurrence: .daily,
            createdAt: letter.createdAt,
            isDelivered: false,
            deliveredAt: nil
        )
        try storage.saveLetter(updated)
        
        let loaded = try storage.loadLetter(letter.id)
        #expect(loaded?.subject == "Updated")
        #expect(loaded?.body == "Updated body")
        #expect(loaded?.recurrence == .daily)
        
        // Should still only be one letter
        let all = try storage.loadAllLetters()
        #expect(all.count == 1)
    }
    
    // MARK: - Data Integrity Tests
    
    @Test func testLetterPersistence() async throws {
        let storage = createTestStorage()
        let futureDate = Date().addingTimeInterval(3600)
        
        let letter = try Letter(
            subject: "Persist Test",
            body: "This should persist across app sessions",
            scheduledDate: futureDate,
            recurrence: .daily
        )
        try storage.saveLetter(letter)
        
        // Create new storage instance (simulating app restart)
        let newStorage = StorageService(userDefaults: UserDefaults(suiteName: "com.mindmail.notification.tests")!)
        
        let loaded = try newStorage.loadLetter(letter.id)
        #expect(loaded != nil)
        #expect(loaded?.subject == "Persist Test")
        #expect(loaded?.body == "This should persist across app sessions")
        #expect(loaded?.recurrence == .daily)
    }
}


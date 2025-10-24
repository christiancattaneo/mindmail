//
//  LetterModelTests.swift
//  mindmailTests
//
//  Created by Christian Cattaneo on 10/24/25.
//

import Testing
import Foundation
@testable import mindmail

struct LetterModelTests {
    
    // MARK: - Valid Letter Creation
    
    @Test func testValidLetterCreation() async throws {
        let futureDate = Date().addingTimeInterval(3600) // 1 hour from now
        let letter = try Letter(
            subject: "Hello Future Me",
            body: "Remember to stay positive!",
            scheduledDate: futureDate,
            recurrence: .once
        )
        
        #expect(letter.subject == "Hello Future Me")
        #expect(letter.body == "Remember to stay positive!")
        #expect(letter.recurrence == .once)
        #expect(letter.isDelivered == false)
        #expect(letter.deliveredAt == nil)
    }
    
    @Test func testLetterWithoutSubject() async throws {
        let futureDate = Date().addingTimeInterval(3600)
        let letter = try Letter(
            subject: nil,
            body: "Body without subject",
            scheduledDate: futureDate,
            recurrence: .daily
        )
        
        #expect(letter.subject == nil)
        #expect(letter.body == "Body without subject")
    }
    
    @Test func testLetterWithEmptySubject() async throws {
        let futureDate = Date().addingTimeInterval(3600)
        let letter = try Letter(
            subject: "   ",
            body: "Body text",
            scheduledDate: futureDate,
            recurrence: .weekly
        )
        
        #expect(letter.subject == nil) // Empty subject should be treated as nil
    }
    
    @Test func testMaxLengthSubject() async throws {
        let futureDate = Date().addingTimeInterval(3600)
        let maxSubject = String(repeating: "A", count: 100)
        let letter = try Letter(
            subject: maxSubject,
            body: "Body",
            scheduledDate: futureDate,
            recurrence: .once
        )
        
        #expect(letter.subject?.count == 100)
    }
    
    @Test func testMaxLengthBody() async throws {
        let futureDate = Date().addingTimeInterval(3600)
        let maxBody = String(repeating: "A", count: 2000)
        let letter = try Letter(
            subject: "Test",
            body: maxBody,
            scheduledDate: futureDate,
            recurrence: .once
        )
        
        #expect(letter.body.count == 2000)
    }
    
    // MARK: - Invalid Letter Creation (Should Throw)
    
    @Test func testEmptyBodyThrows() async throws {
        let futureDate = Date().addingTimeInterval(3600)
        #expect(throws: ValidationError.self) {
            _ = try Letter(
                subject: "Subject",
                body: "",
                scheduledDate: futureDate,
                recurrence: .once
            )
        }
    }
    
    @Test func testWhitespaceOnlyBodyThrows() async throws {
        let futureDate = Date().addingTimeInterval(3600)
        #expect(throws: ValidationError.self) {
            _ = try Letter(
                subject: "Subject",
                body: "   ",
                scheduledDate: futureDate,
                recurrence: .once
            )
        }
    }
    
    @Test func testSubjectTooLongThrows() async throws {
        let futureDate = Date().addingTimeInterval(3600)
        let tooLongSubject = String(repeating: "A", count: 101)
        #expect(throws: ValidationError.self) {
            _ = try Letter(
                subject: tooLongSubject,
                body: "Body",
                scheduledDate: futureDate,
                recurrence: .once
            )
        }
    }
    
    @Test func testBodyTooLongThrows() async throws {
        let futureDate = Date().addingTimeInterval(3600)
        let tooLongBody = String(repeating: "A", count: 2001)
        #expect(throws: ValidationError.self) {
            _ = try Letter(
                subject: "Subject",
                body: tooLongBody,
                scheduledDate: futureDate,
                recurrence: .once
            )
        }
    }
    
    // MARK: - Date Validation Tests (Security)
    
    @Test func testPastDateThrows() async throws {
        let pastDate = Date().addingTimeInterval(-3600) // 1 hour ago
        #expect(throws: LetterError.self) {
            _ = try Letter(
                subject: "Test",
                body: "Body",
                scheduledDate: pastDate,
                recurrence: .once
            )
        }
    }
    
    @Test func testCurrentDateThrows() async throws {
        let now = Date()
        #expect(throws: LetterError.self) {
            _ = try Letter(
                subject: "Test",
                body: "Body",
                scheduledDate: now,
                recurrence: .once
            )
        }
    }
    
    @Test func testMinimumDelayEnforced() async throws {
        let tooSoon = Date().addingTimeInterval(30) // 30 seconds (less than 60 second minimum)
        #expect(throws: LetterError.self) {
            _ = try Letter(
                subject: "Test",
                body: "Body",
                scheduledDate: tooSoon,
                recurrence: .once
            )
        }
    }
    
    @Test func testMinimumDelayValid() async throws {
        let validDate = Date().addingTimeInterval(61) // 61 seconds (just over minimum)
        let letter = try Letter(
            subject: "Test",
            body: "Body",
            scheduledDate: validDate,
            recurrence: .once
        )
        
        #expect(letter.scheduledDate > Date())
    }
    
    // MARK: - Security Tests
    
    @Test func testControlCharactersSanitization() async throws {
        let futureDate = Date().addingTimeInterval(3600)
        let letter = try Letter(
            subject: "Test\u{0000}Bad",
            body: "Test\u{0001}Bad",
            scheduledDate: futureDate,
            recurrence: .once
        )
        
        #expect(!letter.subject!.contains("\u{0000}"))
        #expect(!letter.body.contains("\u{0001}"))
    }
    
    @Test func testNewlinesPreserved() async throws {
        let futureDate = Date().addingTimeInterval(3600)
        let letter = try Letter(
            subject: "Multi\nLine",
            body: "Line 1\nLine 2\nLine 3",
            scheduledDate: futureDate,
            recurrence: .once
        )
        
        #expect(letter.subject!.contains("\n"))
        #expect(letter.body.contains("\n"))
    }
    
    // MARK: - Mark as Delivered Tests
    
    @Test func testMarkAsDelivered() async throws {
        let futureDate = Date().addingTimeInterval(3600)
        let letter = try Letter(
            subject: "Test",
            body: "Body",
            scheduledDate: futureDate,
            recurrence: .once
        )
        
        #expect(letter.isDelivered == false)
        #expect(letter.deliveredAt == nil)
        
        let delivered = letter.markAsDelivered()
        
        #expect(delivered.isDelivered == true)
        #expect(delivered.deliveredAt != nil)
        #expect(delivered.id == letter.id)
        #expect(delivered.body == letter.body)
    }
    
    // MARK: - Codable Tests
    
    @Test func testLetterEncodingDecoding() async throws {
        let futureDate = Date().addingTimeInterval(3600)
        let letter = try Letter(
            subject: "Test Subject",
            body: "Test Body",
            scheduledDate: futureDate,
            recurrence: .weekly
        )
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(letter)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(Letter.self, from: data)
        
        #expect(decoded.id == letter.id)
        #expect(decoded.subject == letter.subject)
        #expect(decoded.body == letter.body)
        #expect(decoded.recurrence == letter.recurrence)
    }
}


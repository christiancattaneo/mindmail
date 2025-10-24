//
//  JournalEntryModelTests.swift
//  mindmailTests
//
//  Created by Christian Cattaneo on 10/24/25.
//

import Testing
import Foundation
@testable import mindmail

struct JournalEntryModelTests {
    
    // MARK: - Valid Entry Creation
    
    @Test func testValidEntryCreation() async throws {
        let entry = try JournalEntry(
            date: Date(),
            mood: .awesome,
            struggle: "Long meeting",
            gratitude: "Beautiful weather",
            memory: "Coffee with friend",
            lookingForward: "Weekend plans"
        )
        
        #expect(entry.id != UUID(uuidString: "00000000-0000-0000-0000-000000000000")!)
        #expect(entry.mood == .awesome)
        #expect(entry.struggle == "Long meeting")
        #expect(entry.gratitude == "Beautiful weather")
        #expect(entry.memory == "Coffee with friend")
        #expect(entry.lookingForward == "Weekend plans")
    }
    
    @Test func testDateNormalization() async throws {
        let now = Date()
        let entry = try JournalEntry(
            date: now,
            mood: .justFine,
            struggle: "Test",
            gratitude: "Test",
            memory: "Test",
            lookingForward: "Test"
        )
        
        let calendar = Calendar.current
        let normalizedDate = calendar.startOfDay(for: now)
        #expect(entry.date == normalizedDate)
    }
    
    @Test func testTextTrimming() async throws {
        let entry = try JournalEntry(
            date: Date(),
            mood: .mixed,
            struggle: "  Trimmed  ",
            gratitude: "  Also trimmed  ",
            memory: "  Me too  ",
            lookingForward: "  Same here  "
        )
        
        #expect(entry.struggle == "Trimmed")
        #expect(entry.gratitude == "Also trimmed")
        #expect(entry.memory == "Me too")
        #expect(entry.lookingForward == "Same here")
    }
    
    @Test func testMaxLengthText() async throws {
        let maxText = String(repeating: "A", count: 140)
        let entry = try JournalEntry(
            date: Date(),
            mood: .exciting,
            struggle: maxText,
            gratitude: maxText,
            memory: maxText,
            lookingForward: maxText
        )
        
        #expect(entry.struggle.count == 140)
        #expect(entry.gratitude.count == 140)
        #expect(entry.memory.count == 140)
        #expect(entry.lookingForward.count == 140)
    }
    
    // MARK: - Invalid Entry Creation (Should Throw)
    
    @Test func testEmptyStruggleThrows() async throws {
        #expect(throws: ValidationError.self) {
            _ = try JournalEntry(
                date: Date(),
                mood: .awesome,
                struggle: "",
                gratitude: "Valid",
                memory: "Valid",
                lookingForward: "Valid"
            )
        }
    }
    
    @Test func testEmptyGratitudeThrows() async throws {
        #expect(throws: ValidationError.self) {
            _ = try JournalEntry(
                date: Date(),
                mood: .awesome,
                struggle: "Valid",
                gratitude: "",
                memory: "Valid",
                lookingForward: "Valid"
            )
        }
    }
    
    @Test func testEmptyMemoryThrows() async throws {
        #expect(throws: ValidationError.self) {
            _ = try JournalEntry(
                date: Date(),
                mood: .awesome,
                struggle: "Valid",
                gratitude: "Valid",
                memory: "",
                lookingForward: "Valid"
            )
        }
    }
    
    @Test func testEmptyLookingForwardThrows() async throws {
        #expect(throws: ValidationError.self) {
            _ = try JournalEntry(
                date: Date(),
                mood: .awesome,
                struggle: "Valid",
                gratitude: "Valid",
                memory: "Valid",
                lookingForward: ""
            )
        }
    }
    
    @Test func testWhitespaceOnlyThrows() async throws {
        #expect(throws: ValidationError.self) {
            _ = try JournalEntry(
                date: Date(),
                mood: .awesome,
                struggle: "   ",
                gratitude: "Valid",
                memory: "Valid",
                lookingForward: "Valid"
            )
        }
    }
    
    @Test func testTextTooLongThrows() async throws {
        let tooLongText = String(repeating: "A", count: 141)
        #expect(throws: ValidationError.self) {
            _ = try JournalEntry(
                date: Date(),
                mood: .awesome,
                struggle: tooLongText,
                gratitude: "Valid",
                memory: "Valid",
                lookingForward: "Valid"
            )
        }
    }
    
    // MARK: - Security Tests
    
    @Test func testControlCharactersSanitization() async throws {
        let entry = try JournalEntry(
            date: Date(),
            mood: .awesome,
            struggle: "Test\u{0000}Bad",
            gratitude: "Test\u{0001}Bad",
            memory: "Test\u{0002}Bad",
            lookingForward: "Test\u{0003}Bad"
        )
        
        #expect(!entry.struggle.contains("\u{0000}"))
        #expect(!entry.gratitude.contains("\u{0001}"))
        #expect(!entry.memory.contains("\u{0002}"))
        #expect(!entry.lookingForward.contains("\u{0003}"))
    }
    
    @Test func testNewlinesPreserved() async throws {
        let entry = try JournalEntry(
            date: Date(),
            mood: .awesome,
            struggle: "Line 1\nLine 2",
            gratitude: "Line 1\nLine 2",
            memory: "Line 1\nLine 2",
            lookingForward: "Line 1\nLine 2"
        )
        
        #expect(entry.struggle.contains("\n"))
    }
    
    // MARK: - Date Key Tests
    
    @Test func testDateKeyFormat() async throws {
        let components = DateComponents(year: 2025, month: 10, day: 24)
        let date = Calendar.current.date(from: components)!
        
        let entry = try JournalEntry(
            date: date,
            mood: .awesome,
            struggle: "Test",
            gratitude: "Test",
            memory: "Test",
            lookingForward: "Test"
        )
        
        #expect(entry.dateKey == "2025-10-24")
    }
    
    // MARK: - Codable Tests
    
    @Test func testEntryEncodingDecoding() async throws {
        let entry = try JournalEntry(
            date: Date(),
            mood: .stressful,
            struggle: "Test struggle",
            gratitude: "Test gratitude",
            memory: "Test memory",
            lookingForward: "Test future"
        )
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(entry)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(JournalEntry.self, from: data)
        
        #expect(decoded.id == entry.id)
        #expect(decoded.mood == entry.mood)
        #expect(decoded.struggle == entry.struggle)
    }
}


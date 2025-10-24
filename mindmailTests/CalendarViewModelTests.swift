//
//  CalendarViewModelTests.swift
//  mindmailTests
//
//  Created by Christian Cattaneo on 10/24/25.
//

import Testing
import Foundation
@testable import mindmail

struct CalendarViewModelTests {
    
    func createTestStorage() -> StorageService {
        let testDefaults = UserDefaults(suiteName: "com.mindmail.calendar.tests")!
        testDefaults.removePersistentDomain(forName: "com.mindmail.calendar.tests")
        return StorageService(userDefaults: testDefaults)
    }
    
    // MARK: - Initialization Tests
    
    @Test func testInitialization() async throws {
        let storage = createTestStorage()
        let viewModel = CalendarViewModel(storage: storage)
        
        #expect(viewModel.currentMonth != Date(timeIntervalSince1970: 0))
        #expect(viewModel.selectedDate == nil)
        #expect(viewModel.journalEntries.isEmpty)
    }
    
    // MARK: - Month Navigation Tests
    
    @Test func testMoveToNextMonth() async throws {
        let storage = createTestStorage()
        let viewModel = CalendarViewModel(storage: storage)
        
        let originalMonth = viewModel.currentMonth
        viewModel.moveToNextMonth()
        
        let calendar = Calendar.current
        let originalComponents = calendar.dateComponents([.year, .month], from: originalMonth)
        let newComponents = calendar.dateComponents([.year, .month], from: viewModel.currentMonth)
        
        // Should be one month later
        if originalComponents.month == 12 {
            #expect(newComponents.month == 1)
            #expect(newComponents.year == (originalComponents.year ?? 0) + 1)
        } else {
            #expect(newComponents.month == (originalComponents.month ?? 0) + 1)
        }
    }
    
    @Test func testMoveToPreviousMonth() async throws {
        let storage = createTestStorage()
        let viewModel = CalendarViewModel(storage: storage)
        
        let originalMonth = viewModel.currentMonth
        viewModel.moveToPreviousMonth()
        
        let calendar = Calendar.current
        let originalComponents = calendar.dateComponents([.year, .month], from: originalMonth)
        let newComponents = calendar.dateComponents([.year, .month], from: viewModel.currentMonth)
        
        // Should be one month earlier
        if originalComponents.month == 1 {
            #expect(newComponents.month == 12)
            #expect(newComponents.year == (originalComponents.year ?? 0) - 1)
        } else {
            #expect(newComponents.month == (originalComponents.month ?? 0) - 1)
        }
    }
    
    @Test func testMoveToToday() async throws {
        let storage = createTestStorage()
        let viewModel = CalendarViewModel(storage: storage)
        
        // Move to a different month
        viewModel.moveToPreviousMonth()
        viewModel.moveToPreviousMonth()
        
        // Move back to today
        viewModel.moveToToday()
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let currentMonth = calendar.startOfDay(for: viewModel.currentMonth)
        
        let todayComponents = calendar.dateComponents([.year, .month], from: today)
        let currentComponents = calendar.dateComponents([.year, .month], from: currentMonth)
        
        #expect(todayComponents.year == currentComponents.year)
        #expect(todayComponents.month == currentComponents.month)
        #expect(viewModel.selectedDate != nil)
    }
    
    // MARK: - Date Calculations Tests
    
    @Test func testMonthYearString() async throws {
        let storage = createTestStorage()
        let viewModel = CalendarViewModel(storage: storage)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        let expected = formatter.string(from: viewModel.currentMonth)
        
        #expect(viewModel.monthYearString == expected)
    }
    
    @Test func testDaysInMonth() async throws {
        let storage = createTestStorage()
        let viewModel = CalendarViewModel(storage: storage)
        
        let calendar = Calendar.current
        let daysInMonth = calendar.range(of: .day, in: .month, for: viewModel.currentMonth)?.count ?? 0
        
        #expect(viewModel.daysInMonth == daysInMonth)
        #expect(viewModel.daysInMonth >= 28)
        #expect(viewModel.daysInMonth <= 31)
    }
    
    @Test func testFirstWeekday() async throws {
        let storage = createTestStorage()
        let viewModel = CalendarViewModel(storage: storage)
        
        #expect(viewModel.firstWeekday >= 1)
        #expect(viewModel.firstWeekday <= 7)
    }
    
    @Test func testDatesForCalendarGrid() async throws {
        let storage = createTestStorage()
        let viewModel = CalendarViewModel(storage: storage)
        
        let dates = viewModel.datesForCalendarGrid()
        
        // Grid should be divisible by 7 (full weeks)
        #expect(dates.count % 7 == 0)
        
        // Should have at least 28 cells (4 weeks)
        #expect(dates.count >= 28)
        
        // Should have at most 42 cells (6 weeks)
        #expect(dates.count <= 42)
        
        // Count non-nil dates
        let nonNilDates = dates.compactMap { $0 }
        #expect(nonNilDates.count == viewModel.daysInMonth)
    }
    
    // MARK: - Date Status Tests
    
    @Test func testIsToday() async throws {
        let storage = createTestStorage()
        let viewModel = CalendarViewModel(storage: storage)
        
        let today = Date()
        #expect(viewModel.isToday(today) == true)
        
        let yesterday = Date().addingTimeInterval(-86400)
        #expect(viewModel.isToday(yesterday) == false)
    }
    
    @Test func testIsFuture() async throws {
        let storage = createTestStorage()
        let viewModel = CalendarViewModel(storage: storage)
        
        let tomorrow = Date().addingTimeInterval(86400)
        #expect(viewModel.isFuture(tomorrow) == true)
        
        let yesterday = Date().addingTimeInterval(-86400)
        #expect(viewModel.isFuture(yesterday) == false)
        
        let today = Date()
        #expect(viewModel.isFuture(today) == false)
    }
    
    @Test func testIsSelected() async throws {
        let storage = createTestStorage()
        let viewModel = CalendarViewModel(storage: storage)
        
        let date = Date()
        #expect(viewModel.isSelected(date) == false)
        
        _ = viewModel.selectDate(date)
        #expect(viewModel.isSelected(date) == true)
        
        let otherDate = Date().addingTimeInterval(86400)
        #expect(viewModel.isSelected(otherDate) == false)
    }
    
    // MARK: - Entry Management Tests
    
    @Test func testLoadEntries() async throws {
        let storage = createTestStorage()
        
        // Add some entries
        let entry1 = try JournalEntry(
            date: Date(),
            mood: .awesome,
            struggle: "Test",
            gratitude: "Test",
            memory: "Test",
            lookingForward: "Test"
        )
        
        let yesterday = Date().addingTimeInterval(-86400)
        let entry2 = try JournalEntry(
            date: yesterday,
            mood: .justFine,
            struggle: "Test2",
            gratitude: "Test2",
            memory: "Test2",
            lookingForward: "Test2"
        )
        
        try storage.saveJournalEntry(entry1)
        try storage.saveJournalEntry(entry2)
        
        // Create view model (should load entries)
        let viewModel = CalendarViewModel(storage: storage)
        
        #expect(viewModel.journalEntries.count == 2)
        #expect(viewModel.hasEntry(for: Date()) == true)
        #expect(viewModel.hasEntry(for: yesterday) == true)
    }
    
    @Test func testEntryForDate() async throws {
        let storage = createTestStorage()
        
        let date = Date()
        let entry = try JournalEntry(
            date: date,
            mood: .exciting,
            struggle: "Challenge",
            gratitude: "Blessing",
            memory: "Moment",
            lookingForward: "Hope"
        )
        
        try storage.saveJournalEntry(entry)
        
        let viewModel = CalendarViewModel(storage: storage)
        
        let retrieved = viewModel.entry(for: date)
        #expect(retrieved != nil)
        #expect(retrieved?.mood == .exciting)
        #expect(retrieved?.struggle == "Challenge")
    }
    
    @Test func testHasEntry() async throws {
        let storage = createTestStorage()
        let viewModel = CalendarViewModel(storage: storage)
        
        let date = Date()
        #expect(viewModel.hasEntry(for: date) == false)
        
        let entry = try JournalEntry(
            date: date,
            mood: .awesome,
            struggle: "Test",
            gratitude: "Test",
            memory: "Test",
            lookingForward: "Test"
        )
        
        try storage.saveJournalEntry(entry)
        viewModel.loadEntries()
        
        #expect(viewModel.hasEntry(for: date) == true)
    }
    
    // MARK: - Selection Tests
    
    @Test func testSelectDate() async throws {
        let storage = createTestStorage()
        let viewModel = CalendarViewModel(storage: storage)
        
        let date = Date()
        let entry = viewModel.selectDate(date)
        
        #expect(viewModel.selectedDate != nil)
        #expect(entry == nil) // No entry exists yet
        
        // Add an entry
        let journalEntry = try JournalEntry(
            date: date,
            mood: .awesome,
            struggle: "Test",
            gratitude: "Test",
            memory: "Test",
            lookingForward: "Test"
        )
        
        try storage.saveJournalEntry(journalEntry)
        viewModel.loadEntries()
        
        let entryRetrieved = viewModel.selectDate(date)
        #expect(entryRetrieved != nil)
        #expect(entryRetrieved?.mood == .awesome)
    }
    
    // MARK: - Edge Cases
    
    @Test func testMonthBoundaries() async throws {
        let storage = createTestStorage()
        let viewModel = CalendarViewModel(storage: storage)
        
        // Navigate through 12 months forward and back
        for _ in 1...12 {
            viewModel.moveToNextMonth()
        }
        
        for _ in 1...12 {
            viewModel.moveToPreviousMonth()
        }
        
        // Should be back to approximately the same month
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let current = calendar.startOfDay(for: viewModel.currentMonth)
        
        let todayComponents = calendar.dateComponents([.year, .month], from: today)
        let currentComponents = calendar.dateComponents([.year, .month], from: current)
        
        #expect(todayComponents.year == currentComponents.year)
        #expect(todayComponents.month == currentComponents.month)
    }
}


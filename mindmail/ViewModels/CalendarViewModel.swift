//
//  CalendarViewModel.swift
//  mindmail
//
//  Created by Christian Cattaneo on 10/24/25.
//

import Foundation
import SwiftUI

/// Manages calendar state, navigation, and journal entry retrieval
/// Handles month navigation and tracks which days have entries
@Observable
class CalendarViewModel {
    private let storage: StorageService
    private let calendar = Calendar.current
    
    // State
    var currentMonth: Date {
        didSet {
            // When month changes, reload calendar
            print("📅 [CalendarViewModel] Month changed to: \(monthYearString)")
        }
    }
    var selectedDate: Date?
    var journalEntries: [String: JournalEntry] = [:] // dateKey: entry
    
    init(storage: StorageService = .shared) {
        self.storage = storage
        self.currentMonth = calendar.startOfDay(for: Date())
        loadEntries()
    }
    
    // MARK: - Data Loading
    
    /// Loads all journal entries from storage
    func loadEntries() {
        do {
            let entries = try storage.loadAllJournalEntries()
            
            // Convert to dictionary for fast lookup
            var entriesDict: [String: JournalEntry] = [:]
            for entry in entries {
                entriesDict[entry.dateKey] = entry
            }
            
            journalEntries = entriesDict
        } catch {
            print("Error loading journal entries: \(error.localizedDescription)")
            journalEntries = [:]
        }
    }
    
    /// Gets entry for a specific date
    func entry(for date: Date) -> JournalEntry? {
        let normalizedDate = calendar.startOfDay(for: date)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateKey = formatter.string(from: normalizedDate)
        
        return journalEntries[dateKey]
    }
    
    /// Checks if a date has an entry
    func hasEntry(for date: Date) -> Bool {
        return entry(for: date) != nil
    }
    
    // MARK: - Month Navigation
    
    /// Moves to the previous month
    func moveToPreviousMonth() {
        guard let newMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) else {
            return
        }
        currentMonth = newMonth
    }
    
    /// Moves to the next month
    func moveToNextMonth() {
        guard let newMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) else {
            return
        }
        currentMonth = newMonth
    }
    
    /// Jumps to today's month
    func moveToToday() {
        currentMonth = calendar.startOfDay(for: Date())
        selectedDate = Date()
    }
    
    // MARK: - Date Calculations
    
    /// Returns the month and year as a string (e.g., "October 2025")
    var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentMonth)
    }
    
    /// Returns the first day of the current month
    var firstDayOfMonth: Date {
        let components = calendar.dateComponents([.year, .month], from: currentMonth)
        return calendar.date(from: components) ?? currentMonth
    }
    
    /// Returns the number of days in the current month
    var daysInMonth: Int {
        return calendar.range(of: .day, in: .month, for: currentMonth)?.count ?? 30
    }
    
    /// Returns the weekday of the first day (1 = Sunday, 7 = Saturday)
    var firstWeekday: Int {
        return calendar.component(.weekday, from: firstDayOfMonth)
    }
    
    /// Returns an array of dates for the calendar grid
    /// Includes padding days from previous/next months
    func datesForCalendarGrid() -> [Date?] {
        var dates: [Date?] = []
        
        // Add padding for days before the first day of month
        let paddingDays = firstWeekday - 1
        for _ in 0..<paddingDays {
            dates.append(nil)
        }
        
        // Add all days in the month
        for day in 1...daysInMonth {
            var components = calendar.dateComponents([.year, .month], from: currentMonth)
            components.day = day
            if let date = calendar.date(from: components) {
                dates.append(date)
            }
        }
        
        // Add padding to complete the last week
        while dates.count % 7 != 0 {
            dates.append(nil)
        }
        
        return dates
    }
    
    /// Checks if a date is today
    func isToday(_ date: Date) -> Bool {
        return calendar.isDateInToday(date)
    }
    
    /// Checks if a date is in the future
    func isFuture(_ date: Date) -> Bool {
        let today = calendar.startOfDay(for: Date())
        let compareDate = calendar.startOfDay(for: date)
        return compareDate > today
    }
    
    /// Checks if a date is selected
    func isSelected(_ date: Date) -> Bool {
        guard let selectedDate = selectedDate else { return false }
        return calendar.isDate(date, inSameDayAs: selectedDate)
    }
    
    // MARK: - Selection
    
    /// Selects a date and returns the entry if it exists
    func selectDate(_ date: Date) -> JournalEntry? {
        selectedDate = date
        return entry(for: date)
    }
}


//
//  RecurrencePattern.swift
//  mindmail
//
//  Created by Christian Cattaneo on 10/24/25.
//

import Foundation

/// Defines how often a letter should be delivered
/// Security: Predefined values prevent injection and ensure safe scheduling
/// Simplified for emotional wellness use case
enum RecurrencePattern: String, Codable, CaseIterable, Identifiable {
    case once = "once"
    case daily = "daily"
    
    var id: String { rawValue }
    
    /// Human-readable label
    var label: String {
        switch self {
        case .once:
            return "One Time"
        case .daily:
            return "Daily Reminder"
        }
    }
    
    /// Icon for the recurrence type
    var icon: String {
        switch self {
        case .once:
            return "envelope.circle.fill"
        case .daily:
            return "repeat.circle.fill"
        }
    }
    
    /// Description of what this means
    var description: String {
        switch self {
        case .once:
            return "Receive this letter once"
        case .daily:
            return "Get this reminder every day"
        }
    }
    
    /// Calendar component for scheduling
    var calendarComponent: Calendar.Component? {
        switch self {
        case .once:
            return nil
        case .daily:
            return .day
        }
    }
}


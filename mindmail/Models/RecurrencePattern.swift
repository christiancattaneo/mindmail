//
//  RecurrencePattern.swift
//  mindmail
//
//  Created by Christian Cattaneo on 10/24/25.
//

import Foundation

/// Defines how often a letter should be delivered
/// Security: Predefined values prevent injection and ensure safe scheduling
enum RecurrencePattern: String, Codable, CaseIterable, Identifiable {
    case once = "once"
    case daily = "daily"
    case weekly = "weekly"
    
    var id: String { rawValue }
    
    /// Human-readable label
    var label: String {
        switch self {
        case .once:
            return "Only Once"
        case .daily:
            return "Daily"
        case .weekly:
            return "Weekly"
        }
    }
    
    /// Calendar component for scheduling
    var calendarComponent: Calendar.Component? {
        switch self {
        case .once:
            return nil
        case .daily:
            return .day
        case .weekly:
            return .weekOfYear
        }
    }
}


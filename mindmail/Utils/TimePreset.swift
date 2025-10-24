//
//  TimePreset.swift
//  mindmail
//
//  Created by Christian Cattaneo on 10/24/25.
//

import Foundation

/// Time preset options for scheduling letters
/// Designed for emotional wellness - popular timeframes for reflection
enum TimePreset: String, CaseIterable, Identifiable {
    case oneWeek = "one_week"
    case oneMonth = "one_month"
    case threeMonths = "three_months"
    case sixMonths = "six_months"
    case oneYear = "one_year"
    case fiveYears = "five_years"
    case custom = "custom"
    
    var id: String { rawValue }
    
    /// Display label for the preset
    var label: String {
        switch self {
        case .oneWeek:
            return "In 1 week"
        case .oneMonth:
            return "In 1 month"
        case .threeMonths:
            return "In 3 months"
        case .sixMonths:
            return "In 6 months"
        case .oneYear:
            return "In 1 year"
        case .fiveYears:
            return "In 5 years"
        case .custom:
            return "Custom..."
        }
    }
    
    /// Icon for the preset
    var icon: String {
        switch self {
        case .oneWeek:
            return "7.circle.fill"
        case .oneMonth:
            return "30.circle.fill"
        case .threeMonths:
            return "calendar.badge.clock"
        case .sixMonths:
            return "leaf.circle.fill"
        case .oneYear:
            return "sparkles"
        case .fiveYears:
            return "star.circle.fill"
        case .custom:
            return "calendar.circle.fill"
        }
    }
    
    /// Calculates the future date based on preset
    /// Returns date at noon for consistency
    func futureDate(from baseDate: Date = Date()) -> Date {
        let calendar = Calendar.current
        let noon = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: baseDate) ?? baseDate
        
        switch self {
        case .oneWeek:
            return calendar.date(byAdding: .day, value: 7, to: noon) ?? noon
        case .oneMonth:
            return calendar.date(byAdding: .month, value: 1, to: noon) ?? noon
        case .threeMonths:
            return calendar.date(byAdding: .month, value: 3, to: noon) ?? noon
        case .sixMonths:
            return calendar.date(byAdding: .month, value: 6, to: noon) ?? noon
        case .oneYear:
            return calendar.date(byAdding: .year, value: 1, to: noon) ?? noon
        case .fiveYears:
            return calendar.date(byAdding: .year, value: 5, to: noon) ?? noon
        case .custom:
            return noon
        }
    }
    
    /// Friendly description of when the letter will arrive
    var description: String {
        switch self {
        case .oneWeek:
            return "A quick check-in with near-future you"
        case .oneMonth:
            return "See how next month treats you"
        case .threeMonths:
            return "A seasonal reflection"
        case .sixMonths:
            return "Your 6-month future self"
        case .oneYear:
            return "A letter to next year's you"
        case .fiveYears:
            return "A time capsule for future you"
        case .custom:
            return "Pick your own special date"
        }
    }
}


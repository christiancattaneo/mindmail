//
//  MoodType.swift
//  mindmail
//
//  Created by Christian Cattaneo on 10/24/25.
//

import Foundation

/// Represents the user's mood for a given day
/// Security: All values are predefined to prevent injection
enum MoodType: String, Codable, CaseIterable, Identifiable {
    case awesome = "😊"
    case justFine = "😌"
    case exciting = "🎉"
    case boring = "😴"
    case stressful = "😰"
    case mixed = "💭"
    
    var id: String { rawValue }
    
    /// Human-readable label for the mood
    var label: String {
        switch self {
        case .awesome:
            return "Awesome"
        case .justFine:
            return "Just fine"
        case .exciting:
            return "Exciting"
        case .boring:
            return "Boring"
        case .stressful:
            return "Stressful"
        case .mixed:
            return "Mixed"
        }
    }
    
    /// Emoji representation
    var emoji: String {
        return rawValue
    }
}


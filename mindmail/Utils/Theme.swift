//
//  Theme.swift
//  mindmail
//
//  Created by Christian Cattaneo on 10/24/25.
//

import SwiftUI

/// Centralized theme system for consistent design across the app
/// Based on aesthetic.md design guide
enum Theme {
    
    // MARK: - Colors
    
    /// Primary brand colors (from PRD and aesthetic.md)
    enum Colors {
        // Primary Pastel Colors (from PRD)
        static let lavender = Color(hex: "f0e6ff")
        static let lavenderDark = Color(hex: "d0b8ff")
        
        static let peach = Color(hex: "ffceb8")
        static let peachLight = Color(hex: "ffe4d4")
        
        static let skyBlue = Color(hex: "b8e6ff")
        static let skyBlueLight = Color(hex: "d4f0ff")
        
        static let rose = Color(hex: "ffe4f3")
        static let roseLight = Color(hex: "f3e4ff")
        
        // Additional colors from aesthetic.md
        static let softLavender = Color(hex: "E8E0F5")
        static let palePink = Color(hex: "F5E8F0")
        static let lightBlue = Color(hex: "E0EFF5")
        static let creamIvory = Color(hex: "FFFEF8")
        
        static let mutedPeach = Color(hex: "F5DCC8")
        static let softPurple = Color(hex: "D8C8F0")
        static let paleBlue = Color(hex: "C8E0F5")
        static let cherryBlossomPink = Color(hex: "F5B8D8")
        
        // Text colors
        static let textPrimary = Color(hex: "2d2d3a")
        static let textSecondary = Color(hex: "8b8b9a")
        
        // Semantic colors
        static let background = LinearGradient(
            colors: [softLavender, creamIvory],
            startPoint: .top,
            endPoint: .bottom
        )
        
        static let cardBackground = Color.white.opacity(0.7)
        static let cardShadow = Color.black.opacity(0.1)
    }
    
    // MARK: - Typography
    
    enum Typography {
        // Font sizes
        static let largeTitle: CGFloat = 34
        static let title: CGFloat = 28
        static let title2: CGFloat = 22
        static let title3: CGFloat = 20
        static let headline: CGFloat = 17
        static let body: CGFloat = 17
        static let callout: CGFloat = 16
        static let subheadline: CGFloat = 15
        static let footnote: CGFloat = 13
        static let caption: CGFloat = 12
        
        // Font weights
        static let light: Font.Weight = .light
        static let regular: Font.Weight = .regular
        static let medium: Font.Weight = .medium
        static let semibold: Font.Weight = .semibold
        static let bold: Font.Weight = .bold
    }
    
    // MARK: - Spacing
    
    enum Spacing {
        static let xxxSmall: CGFloat = 4
        static let xxSmall: CGFloat = 8
        static let xSmall: CGFloat = 12
        static let small: CGFloat = 16
        static let medium: CGFloat = 20
        static let large: CGFloat = 24
        static let xLarge: CGFloat = 32
        static let xxLarge: CGFloat = 40
        static let xxxLarge: CGFloat = 48
    }
    
    // MARK: - Corner Radius
    
    enum CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let xLarge: CGFloat = 20
        static let xxLarge: CGFloat = 24
        static let xxxLarge: CGFloat = 30
    }
    
    // MARK: - Shadows
    
    enum Shadow {
        static let subtle = (color: Colors.cardShadow, radius: CGFloat(8), x: CGFloat(0), y: CGFloat(2))
        static let medium = (color: Colors.cardShadow, radius: CGFloat(12), x: CGFloat(0), y: CGFloat(4))
        static let strong = (color: Colors.cardShadow, radius: CGFloat(16), x: CGFloat(0), y: CGFloat(6))
    }
    
    // MARK: - Animation
    
    enum Animation {
        static let quick = SwiftUI.Animation.easeInOut(duration: 0.2)
        static let standard = SwiftUI.Animation.easeInOut(duration: 0.3)
        static let smooth = SwiftUI.Animation.easeInOut(duration: 0.4)
        static let slow = SwiftUI.Animation.easeInOut(duration: 0.6)
        
        static let spring = SwiftUI.Animation.spring(response: 0.3, dampingFraction: 0.7)
        static let springBouncy = SwiftUI.Animation.spring(response: 0.4, dampingFraction: 0.6)
    }
    
    // MARK: - Touch Targets
    
    enum TouchTarget {
        /// Minimum recommended touch target size (44x44 points)
        static let minimum: CGFloat = 44
        
        /// Comfortable touch target size
        static let comfortable: CGFloat = 48
        
        /// Large touch target for primary actions
        static let large: CGFloat = 56
    }
    
    // MARK: - Mood Colors
    
    /// Colors associated with each mood type
    static func colorForMood(_ mood: MoodType) -> Color {
        switch mood {
        case .awesome:
            return Colors.cherryBlossomPink
        case .justFine:
            return Colors.paleBlue
        case .exciting:
            return Colors.peach
        case .boring:
            return Colors.softPurple
        case .stressful:
            return Colors.lavenderDark
        case .mixed:
            return Colors.rose
        }
    }
}

// MARK: - Color Extension

extension Color {
    /// Creates a color from a hex string
    /// - Parameter hex: Hex string (with or without #)
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - View Modifiers

extension View {
    /// Applies a standard card style with shadow
    func cardStyle() -> some View {
        self
            .background(Theme.Colors.cardBackground)
            .cornerRadius(Theme.CornerRadius.large)
            .shadow(
                color: Theme.Shadow.subtle.color,
                radius: Theme.Shadow.subtle.radius,
                x: Theme.Shadow.subtle.x,
                y: Theme.Shadow.subtle.y
            )
    }
    
    /// Applies the theme background gradient
    func themeBackground() -> some View {
        self.background(Theme.Colors.background.ignoresSafeArea())
    }
}


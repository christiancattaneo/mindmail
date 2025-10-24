//
//  MoodSelectionView.swift
//  mindmail
//
//  Created by Christian Cattaneo on 10/24/25.
//

import SwiftUI

/// Mood selection screen - Step 1 of journal entry
/// Design: 6 emoji grid with beautiful animations
struct MoodSelectionView: View {
    @Binding var selectedMood: MoodType?
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: Theme.Spacing.medium), count: 3)
    
    var body: some View {
        VStack(spacing: Theme.Spacing.xLarge) {
            LazyVGrid(columns: columns, spacing: Theme.Spacing.medium) {
                ForEach(MoodType.allCases) { mood in
                    MoodButton(
                        mood: mood,
                        isSelected: selectedMood == mood
                    ) {
                        withAnimation(Theme.Animation.spring) {
                            selectedMood = mood
                        }
                        
                        // Haptic feedback
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                    }
                }
            }
            .padding(.horizontal, Theme.Spacing.large)
        }
    }
}

// MARK: - Mood Button

struct MoodButton: View {
    let mood: MoodType
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: Theme.Spacing.xSmall) {
                // Emoji
                Text(mood.emoji)
                    .font(.system(size: 50))
                    .scaleEffect(isSelected ? 1.1 : 1.0)
                
                // Label
                Text(mood.label)
                    .font(.system(size: Theme.Typography.subheadline, weight: isSelected ? Theme.Typography.semibold : Theme.Typography.regular))
                    .foregroundColor(isSelected ? Theme.Colors.textPrimary : Theme.Colors.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Theme.Spacing.medium)
            .background(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.large)
                    .fill(isSelected ? Theme.colorForMood(mood).opacity(0.3) : Theme.Colors.cardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.large)
                    .strokeBorder(isSelected ? Theme.colorForMood(mood) : Color.clear, lineWidth: 2)
            )
            .shadow(
                color: isSelected ? Theme.Shadow.medium.color : Theme.Shadow.subtle.color,
                radius: isSelected ? Theme.Shadow.medium.radius : Theme.Shadow.subtle.radius,
                x: 0,
                y: isSelected ? Theme.Shadow.medium.y : Theme.Shadow.subtle.y
            )
        }
        .animation(Theme.Animation.spring, value: isSelected)
    }
}

#Preview {
    @Previewable @State var selectedMood: MoodType? = nil
    
    VStack {
        MoodSelectionView(selectedMood: $selectedMood)
    }
    .themeBackground()
}


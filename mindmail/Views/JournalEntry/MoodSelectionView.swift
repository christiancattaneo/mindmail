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
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: Theme.Spacing.small) {
                // Emoji with subtle background when selected
                ZStack {
                    if isSelected {
                        Circle()
                            .fill(Theme.colorForMood(mood).opacity(0.25))
                            .frame(width: 65, height: 65)
                    }
                    
                    Text(mood.emoji)
                        .font(.system(size: 52))
                        .scaleEffect(isSelected ? 1.1 : 1.0)
                }
                
                // Label
                Text(mood.label)
                    .font(.system(size: Theme.Typography.footnote, weight: isSelected ? Theme.Typography.bold : Theme.Typography.semibold))
                    .foregroundColor(isSelected ? Theme.Colors.textPrimary : Theme.Colors.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Theme.Spacing.large)
            .background(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.xLarge)
                    .fill(
                        isSelected ? 
                        LinearGradient(
                            colors: [
                                Theme.colorForMood(mood).opacity(0.4),
                                Theme.colorForMood(mood).opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        LinearGradient(
                            colors: [Theme.Colors.cardBackground, Theme.Colors.cardBackground],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.xLarge)
                    .strokeBorder(
                        isSelected ? 
                        LinearGradient(
                            colors: [Theme.colorForMood(mood), Theme.colorForMood(mood).opacity(0.5)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) : 
                        LinearGradient(colors: [Color.clear, Color.clear], startPoint: .top, endPoint: .bottom),
                        lineWidth: isSelected ? 2.5 : 0
                    )
            )
            .shadow(
                color: isSelected ? Theme.colorForMood(mood).opacity(0.3) : Theme.Shadow.subtle.color,
                radius: isSelected ? 12 : Theme.Shadow.subtle.radius,
                x: 0,
                y: isSelected ? 4 : Theme.Shadow.subtle.y
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = false
                    }
                }
        )
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


//
//  JournalEntryDisplayView.swift
//  mindmail
//
//  Created by Christian Cattaneo on 10/24/25.
//

import SwiftUI

/// Beautiful display view for saved journal entries
/// Shows all answers aesthetically with edit option
struct JournalEntryDisplayView: View {
    let entry: JournalEntry
    let onEdit: () -> Void
    let onClose: () -> Void
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        return formatter.string(from: entry.date)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.Spacing.large) {
                    // Mood Header
                    moodHeader
                    
                    // Entry Sections
                    entrySection(
                        title: "One Struggle",
                        icon: "cloud.rain.fill",
                        color: Theme.Colors.skyBlue,
                        content: entry.struggle
                    )
                    
                    entrySection(
                        title: "Gratitude",
                        icon: "heart.fill",
                        color: Theme.Colors.cherryBlossomPink,
                        content: entry.gratitude
                    )
                    
                    entrySection(
                        title: "Memory to Keep",
                        icon: "star.fill",
                        color: Theme.Colors.peach,
                        content: entry.memory
                    )
                    
                    entrySection(
                        title: "Looking Forward",
                        icon: "sparkles",
                        color: Theme.Colors.lavenderDark,
                        content: entry.lookingForward
                    )
                    
                    Spacer(minLength: Theme.Spacing.xxLarge)
                }
                .padding(Theme.Spacing.large)
            }
            .background(
                LinearGradient(
                    colors: [Theme.Colors.softLavender, Theme.Colors.creamIvory],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        onClose()
                    }
                    .foregroundColor(Theme.Colors.textSecondary)
                }
                
                ToolbarItem(placement: .principal) {
                    Text(formattedDate)
                        .font(.system(size: Theme.Typography.subheadline, weight: Theme.Typography.semibold))
                        .foregroundColor(Theme.Colors.textSecondary)
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button(action: onEdit) {
                        Text("Edit")
                            .font(.system(size: Theme.Typography.body, weight: Theme.Typography.semibold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Theme.Colors.lavenderDark, Theme.Colors.cherryBlossomPink],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    }
                }
            }
        }
    }
    
    // MARK: - Mood Header
    
    private var moodHeader: some View {
        VStack(spacing: Theme.Spacing.medium) {
            // Large mood emoji with glow
            ZStack {
                Circle()
                    .fill(Theme.colorForMood(entry.mood).opacity(0.2))
                    .frame(width: 100, height: 100)
                
                Text(entry.mood.emoji)
                    .font(.system(size: 60))
            }
            
            // Mood label
            Text(entry.mood.label)
                .font(.system(size: Theme.Typography.title2, weight: Theme.Typography.bold))
                .foregroundColor(Theme.Colors.textPrimary)
            
            Text("How you felt")
                .font(.system(size: Theme.Typography.caption, weight: Theme.Typography.regular))
                .foregroundColor(Theme.Colors.textSecondary)
        }
        .padding(.top, Theme.Spacing.medium)
    }
    
    // MARK: - Entry Section
    
    private func entrySection(title: String, icon: String, color: Color, content: String) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.small) {
            // Section header
            HStack(spacing: Theme.Spacing.xSmall) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.system(size: Theme.Typography.headline, weight: Theme.Typography.bold))
                    .foregroundColor(Theme.Colors.textPrimary)
            }
            
            // Content card
            Text(content)
                .font(.system(size: Theme.Typography.body, weight: Theme.Typography.regular))
                .foregroundColor(Theme.Colors.textPrimary)
                .lineSpacing(6)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(Theme.Spacing.medium)
                .background(Theme.Colors.cardBackground)
                .cornerRadius(Theme.CornerRadius.large)
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.CornerRadius.large)
                        .strokeBorder(
                            LinearGradient(
                                colors: [color.opacity(0.3), color.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        }
    }
}

#Preview {
    let entry = try! JournalEntry(
        date: Date(),
        mood: .awesome,
        struggle: "Long day at work with many meetings",
        gratitude: "My supportive team and good coffee",
        memory: "Lunch with a friend in the park",
        lookingForward: "Weekend plans and time to rest"
    )
    
    return JournalEntryDisplayView(
        entry: entry,
        onEdit: {},
        onClose: {}
    )
}


//
//  LetterReadingView.swift
//  mindmail
//
//  Created by Christian Cattaneo on 10/24/25.
//

import SwiftUI

/// Full-screen letter reading view
/// Design: Clean, focused reading experience with paper-like background
struct LetterReadingView: View {
    let letter: Letter
    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteConfirmation = false
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter.string(from: letter.scheduledDate)
    }
    
    private var createdDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: letter.createdAt)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: Theme.Spacing.large) {
                        // Header
                        VStack(alignment: .leading, spacing: Theme.Spacing.xSmall) {
                            if let subject = letter.subject {
                                Text(subject)
                                    .font(.system(size: Theme.Typography.title, weight: Theme.Typography.bold))
                                    .foregroundColor(Theme.Colors.textPrimary)
                            }
                            
                            Text("Written on \(createdDate)")
                                .font(.system(size: Theme.Typography.caption, weight: Theme.Typography.regular))
                                .foregroundColor(Theme.Colors.textSecondary)
                            
                            Text("Scheduled for \(formattedDate)")
                                .font(.system(size: Theme.Typography.caption, weight: Theme.Typography.regular))
                                .foregroundColor(Theme.Colors.textSecondary)
                        }
                        
                        Divider()
                            .background(Theme.Colors.textSecondary.opacity(0.2))
                        
                        // Letter body
                        Text(letter.body)
                            .font(.system(size: Theme.Typography.body, weight: Theme.Typography.regular))
                            .foregroundColor(Theme.Colors.textPrimary)
                            .lineSpacing(8)
                        
                        Spacer(minLength: Theme.Spacing.xxLarge)
                    }
                    .padding(Theme.Spacing.large)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                // Delete button (only for scheduled letters)
                if !letter.isDelivered {
                    deleteButton
                }
            }
            .background(Theme.Colors.creamIvory)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: Theme.Typography.body, weight: Theme.Typography.semibold))
                            .foregroundColor(Theme.Colors.textSecondary)
                    }
                }
            }
            .alert("Delete Letter?", isPresented: $showDeleteConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    deleteLetter()
                }
            } message: {
                Text("This letter will be permanently deleted and won't be delivered.")
            }
        }
    }
    
    // MARK: - Delete Button
    
    private var deleteButton: some View {
        Button(action: {
            showDeleteConfirmation = true
        }) {
            HStack(spacing: Theme.Spacing.xxSmall) {
                Image(systemName: "trash.circle")
                    .font(.system(size: Theme.Typography.footnote))
                Text("Delete")
                    .font(.system(size: Theme.Typography.footnote, weight: Theme.Typography.medium))
            }
            .foregroundColor(Theme.Colors.textSecondary)
            .padding(.horizontal, Theme.Spacing.medium)
            .padding(.vertical, Theme.Spacing.small)
            .background(Theme.Colors.cardBackground)
            .cornerRadius(Theme.CornerRadius.large)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.large)
                    .strokeBorder(Theme.Colors.textSecondary.opacity(0.3), lineWidth: 1)
            )
        }
        .padding(Theme.Spacing.medium)
    }
    
    // MARK: - Actions
    
    private func deleteLetter() {
        do {
            try StorageService.shared.deleteLetter(letter.id)
            
            // Cancel notification if scheduled
            NotificationService.shared.cancelLetter(letter.id)
            
            // Haptic feedback
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
            dismiss()
        } catch {
            // Error haptic
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        }
    }
}

#Preview {
    let letter = try! Letter(
        subject: "Remember This",
        body: "Dear Future Me,\n\nI hope you're doing well. Remember to stay positive and keep moving forward. The challenges you face today are preparing you for tomorrow.\n\nWith love,\nPast You",
        scheduledDate: Date().addingTimeInterval(86400),
        recurrence: .once
    )
    
    return LetterReadingView(letter: letter)
}


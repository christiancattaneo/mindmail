//
//  LetterInboxView.swift
//  mindmail
//
//  Created by Christian Cattaneo on 10/24/25.
//

import SwiftUI

/// Inbox view showing all scheduled and delivered letters
/// Design: Clean list with soft cards showing letter info
struct LetterInboxView: View {
    @State private var letters: [Letter] = []
    @State private var showCompose = false
    @State private var selectedLetter: Letter?
    
    private let storage = StorageService.shared
    
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Colors.background
                    .ignoresSafeArea()
                
                if letters.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        VStack(spacing: Theme.Spacing.medium) {
                            lettersSection(title: "Scheduled", letters: scheduledLetters)
                            lettersSection(title: "Received", letters: deliveredLetters)
                        }
                        .padding(Theme.Spacing.medium)
                    }
                }
            }
            .navigationTitle("Mental Mailbox")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        showCompose = true
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: Theme.Typography.body, weight: Theme.Typography.semibold))
                    }
                }
            }
            .sheet(isPresented: $showCompose) {
                ComposeLetterView()
            }
            .sheet(item: $selectedLetter) { letter in
                LetterReadingView(letter: letter)
            }
            .onAppear {
                loadLetters()
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: Theme.Spacing.large) {
            Spacer()
            
            Text("💌")
                .font(.system(size: 80))
            
            VStack(spacing: Theme.Spacing.small) {
                Text("No Letters Yet")
                    .font(.system(size: Theme.Typography.title2, weight: Theme.Typography.bold))
                    .foregroundColor(Theme.Colors.textPrimary)
                
                Text("Send a letter to your future self!")
                    .font(.system(size: Theme.Typography.body, weight: Theme.Typography.regular))
                    .foregroundColor(Theme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Theme.Spacing.large)
            }
            
            Button(action: {
                showCompose = true
            }) {
                Text("Write First Letter")
                    .font(.system(size: Theme.Typography.headline, weight: Theme.Typography.semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: 280)
                    .padding(.vertical, Theme.Spacing.medium)
                    .background(
                        LinearGradient(
                            colors: [Theme.Colors.lavenderDark, Theme.Colors.softPurple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(Theme.CornerRadius.large)
                    .shadow(
                        color: Theme.Shadow.medium.color,
                        radius: Theme.Shadow.medium.radius,
                        x: Theme.Shadow.medium.x,
                        y: Theme.Shadow.medium.y
                    )
            }
            .padding(.horizontal, Theme.Spacing.large)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Letters Section
    
    @ViewBuilder
    private func lettersSection(title: String, letters: [Letter]) -> some View {
        if !letters.isEmpty {
            VStack(alignment: .leading, spacing: Theme.Spacing.small) {
                Text(title)
                    .font(.system(size: Theme.Typography.headline, weight: Theme.Typography.bold))
                    .foregroundColor(Theme.Colors.textPrimary)
                    .padding(.horizontal, Theme.Spacing.xxSmall)
                
                ForEach(letters) { letter in
                    LetterCard(letter: letter) {
                        selectedLetter = letter
                    }
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var scheduledLetters: [Letter] {
        letters.filter { !$0.isDelivered }.sorted { $0.scheduledDate < $1.scheduledDate }
    }
    
    private var deliveredLetters: [Letter] {
        letters.filter { $0.isDelivered }.sorted { $0.deliveredAt ?? $0.createdAt > $1.deliveredAt ?? $1.createdAt }
    }
    
    // MARK: - Data Loading
    
    private func loadLetters() {
        do {
            letters = try storage.loadAllLetters()
        } catch {
            print("Error loading letters: \(error.localizedDescription)")
            letters = []
        }
    }
}

// MARK: - Letter Card

struct LetterCard: View {
    let letter: Letter
    let onTap: () -> Void
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: letter.scheduledDate)
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Theme.Spacing.medium) {
                // Icon
                ZStack {
                    Circle()
                        .fill(letter.isDelivered ? Theme.Colors.cherryBlossomPink.opacity(0.3) : Theme.Colors.lavender.opacity(0.3))
                        .frame(width: 50, height: 50)
                    
                    Text(letter.isDelivered ? "📬" : "📭")
                        .font(.system(size: 24))
                }
                
                // Content
                VStack(alignment: .leading, spacing: Theme.Spacing.xxxSmall) {
                    if let subject = letter.subject {
                        Text(subject)
                            .font(.system(size: Theme.Typography.subheadline, weight: Theme.Typography.semibold))
                            .foregroundColor(Theme.Colors.textPrimary)
                            .lineLimit(1)
                    }
                    
                    Text(letter.body)
                        .font(.system(size: Theme.Typography.caption, weight: Theme.Typography.regular))
                        .foregroundColor(Theme.Colors.textSecondary)
                        .lineLimit(2)
                    
                    HStack(spacing: Theme.Spacing.xxSmall) {
                        Text(formattedDate)
                            .font(.system(size: Theme.Typography.caption, weight: Theme.Typography.regular))
                            .foregroundColor(Theme.Colors.textSecondary)
                        
                        if letter.recurrence != .once {
                            Text("•")
                                .foregroundColor(Theme.Colors.textSecondary)
                            Text(letter.recurrence.label)
                                .font(.system(size: Theme.Typography.caption, weight: Theme.Typography.medium))
                                .foregroundColor(Theme.Colors.lavenderDark)
                        }
                    }
                }
                
                Spacer()
                
                // Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: Theme.Typography.caption, weight: Theme.Typography.semibold))
                    .foregroundColor(Theme.Colors.textSecondary)
            }
            .padding(Theme.Spacing.medium)
            .background(Theme.Colors.cardBackground)
            .cornerRadius(Theme.CornerRadius.large)
            .shadow(
                color: Theme.Shadow.subtle.color,
                radius: Theme.Shadow.subtle.radius,
                x: Theme.Shadow.subtle.x,
                y: Theme.Shadow.subtle.y
            )
        }
    }
}

#Preview {
    LetterInboxView()
}


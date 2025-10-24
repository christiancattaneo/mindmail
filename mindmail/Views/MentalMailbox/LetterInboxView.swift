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
    @State private var emojiOffset: CGFloat = 0
    
    private let storage = StorageService.shared
    
    var body: some View {
        ZStack {
            Theme.Colors.background
                .ignoresSafeArea()
            
            VStack(spacing: Theme.Spacing.medium) {
                // Custom header matching calendar style
                customHeader
                
                if letters.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        VStack(spacing: Theme.Spacing.large) {
                            lettersSection(title: "Scheduled", letters: scheduledLetters)
                            lettersSection(title: "Received", letters: deliveredLetters)
                        }
                        .padding(.horizontal, Theme.Spacing.medium)
                    }
                }
            }
            .padding(.top, Theme.Spacing.medium)
        }
        .sheet(isPresented: $showCompose) {
            loadLetters()
        } content: {
            ComposeLetterView()
        }
        .sheet(item: $selectedLetter) { letter in
            LetterReadingView(letter: letter)
        }
        .onAppear {
            print("👀 [LetterInboxView] View appeared")
            LetterDeliveryService.shared.checkAndDeliverPastDueLetters()
            loadLetters()
        }
        .refreshable {
            LetterDeliveryService.shared.checkAndDeliverPastDueLetters()
            loadLetters()
        }
        .onReceive(NotificationCenter.default.publisher(for: .letterDelivered)) { _ in
            print("📬 [LetterInboxView] Letter delivered notification received - reloading")
            loadLetters()
        }
    }
    
    // MARK: - Custom Header
    
    private var customHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: Theme.Spacing.xxxSmall) {
                Text("Mental Mailbox")
                    .font(.system(size: Theme.Typography.largeTitle, weight: Theme.Typography.bold))
                    .foregroundColor(Theme.Colors.textPrimary)
                
                Text("Letters from your past self")
                    .font(.system(size: Theme.Typography.body, weight: Theme.Typography.regular))
                    .foregroundColor(Theme.Colors.textSecondary)
            }
            
            Spacer()
            
            // Add button
            Button(action: {
                showCompose = true
            }) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Theme.Colors.lavenderDark, Theme.Colors.cherryBlossomPink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Theme.Spacing.medium)
        .padding(.bottom, Theme.Spacing.small)
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: Theme.Spacing.large) {
            Spacer()
            
            Text("💌")
                .font(.system(size: 80))
                .offset(y: emojiOffset)
                .task {
                    withAnimation(
                        .easeInOut(duration: 2.5)
                        .repeatForever(autoreverses: true)
                    ) {
                        emojiOffset = -8
                    }
                }
            
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
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        if !letter.isDelivered {
                            Button(role: .destructive) {
                                deleteLetter(letter)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
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
    
    // MARK: - Actions
    
    private func deleteLetter(_ letter: Letter) {
        do {
            try storage.deleteLetter(letter.id)
            
            // Cancel notification if scheduled
            NotificationService.shared.cancelLetter(letter.id)
            
            // Reload letters
            loadLetters()
            
            // Haptic feedback
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        } catch {
            print("Error deleting letter: \(error.localizedDescription)")
            
            // Error haptic
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        }
    }
}

// MARK: - Letter Card

struct LetterCard: View {
    let letter: Letter
    let onTap: () -> Void
    
    @State private var isPressed = false
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: letter.scheduledDate)
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Theme.Spacing.medium) {
                // Icon with gradient background
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: letter.isDelivered ? 
                                    [Theme.Colors.cherryBlossomPink.opacity(0.4), Theme.Colors.cherryBlossomPink.opacity(0.2)] :
                                    [Theme.Colors.lavender.opacity(0.4), Theme.Colors.paleBlue.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 56, height: 56)
                    
                    Text(letter.isDelivered ? "💌" : "📮")
                        .font(.system(size: 26))
                }
                
                // Content
                VStack(alignment: .leading, spacing: Theme.Spacing.xxxSmall) {
                    if let subject = letter.subject {
                        Text(subject)
                            .font(.system(size: Theme.Typography.body, weight: Theme.Typography.bold))
                            .foregroundColor(Theme.Colors.textPrimary)
                            .lineLimit(1)
                    }
                    
                    Text(letter.body)
                        .font(.system(size: Theme.Typography.subheadline, weight: Theme.Typography.regular))
                        .foregroundColor(Theme.Colors.textSecondary)
                        .lineLimit(2)
                    
                    HStack(spacing: Theme.Spacing.xxSmall) {
                        Image(systemName: letter.isDelivered ? "checkmark.circle.fill" : "clock.fill")
                            .font(.system(size: 10))
                            .foregroundColor(letter.isDelivered ? Theme.Colors.cherryBlossomPink : Theme.Colors.lavenderDark)
                        
                        Text(formattedDate)
                            .font(.system(size: Theme.Typography.caption, weight: Theme.Typography.medium))
                            .foregroundColor(Theme.Colors.textSecondary)
                        
                        if letter.recurrence != .once {
                            Image(systemName: "repeat.circle.fill")
                                .font(.system(size: 10))
                                .foregroundColor(Theme.Colors.lavenderDark)
                            Text(letter.recurrence.label)
                                .font(.system(size: Theme.Typography.caption, weight: Theme.Typography.bold))
                                .foregroundColor(Theme.Colors.lavenderDark)
                        }
                    }
                }
                
                Spacer()
                
                // Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: Theme.Typography.subheadline, weight: Theme.Typography.bold))
                    .foregroundColor(Theme.Colors.lavenderDark.opacity(0.5))
            }
            .padding(Theme.Spacing.medium)
            .background(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.xLarge)
                    .fill(Theme.Colors.cardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.xLarge)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Theme.Colors.lavender.opacity(0.3),
                                Theme.Colors.paleBlue.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(
                color: isPressed ? Theme.Shadow.medium.color : Theme.Shadow.subtle.color,
                radius: isPressed ? Theme.Shadow.medium.radius : Theme.Shadow.subtle.radius,
                x: 0,
                y: isPressed ? Theme.Shadow.medium.y : Theme.Shadow.subtle.y
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
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
    }
}

#Preview {
    LetterInboxView()
}


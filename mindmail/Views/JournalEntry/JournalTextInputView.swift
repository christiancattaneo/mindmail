//
//  JournalTextInputView.swift
//  mindmail
//
//  Created by Christian Cattaneo on 10/24/25.
//

import SwiftUI

/// Reusable text input view for journal entry steps 2-5
/// Design: Multi-line text input with character counter and validation
struct JournalTextInputView: View {
    let placeholder: String
    @Binding var text: String
    let maxLength: Int = JournalEntry.maxTextLength
    @FocusState.Binding var isFocused: Bool
    
    private var remainingCharacters: Int {
        ValidationUtils.remainingCharacters(text, maxLength: maxLength)
    }
    
    private var isNearLimit: Bool {
        remainingCharacters < 20
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.small) {
            // Text editor
            ZStack(alignment: .topLeading) {
                // Placeholder
                if text.isEmpty {
                    Text(placeholder)
                        .font(.system(size: Theme.Typography.body, weight: Theme.Typography.regular))
                        .foregroundColor(Theme.Colors.textSecondary.opacity(0.6))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 12)
                }
                
                // Text editor
                TextEditor(text: $text)
                    .font(.system(size: Theme.Typography.body, weight: Theme.Typography.regular))
                    .foregroundColor(Theme.Colors.textPrimary)
                    .scrollContentBackground(.hidden)
                    .focused($isFocused)
                    .frame(minHeight: 120)
                    .onChange(of: text) { _, newValue in
                        // Enforce max length
                        if newValue.count > maxLength {
                            text = String(newValue.prefix(maxLength))
                        }
                    }
                    .onAppear {
                        print("📝 [JournalTextInputView] TextEditor appeared")
                    }
            }
            .padding(Theme.Spacing.small)
            .background(Theme.Colors.cardBackground)
            .cornerRadius(Theme.CornerRadius.large)
            .shadow(
                color: isFocused ? Theme.Shadow.medium.color : Theme.Shadow.subtle.color,
                radius: isFocused ? Theme.Shadow.medium.radius : Theme.Shadow.subtle.radius,
                x: 0,
                y: isFocused ? Theme.Shadow.medium.y : Theme.Shadow.subtle.y
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.large)
                    .strokeBorder(isFocused ? Theme.Colors.lavenderDark.opacity(0.5) : Color.clear, lineWidth: 2)
            )
            .animation(Theme.Animation.quick, value: isFocused)
            
            // Character counter
            HStack {
                Spacer()
                
                Text("\(remainingCharacters) characters remaining")
                    .font(.system(size: Theme.Typography.caption, weight: Theme.Typography.regular))
                    .foregroundColor(isNearLimit ? .orange : Theme.Colors.textSecondary)
            }
        }
        .padding(.horizontal, Theme.Spacing.large)
    }
}

#Preview {
    @Previewable @State var text = ""
    @Previewable @FocusState var isFocused: Bool
    
    VStack {
        JournalTextInputView(
            placeholder: "What challenged you...",
            text: $text,
            isFocused: $isFocused
        )
    }
    .themeBackground()
}


//
//  PersonalizationView.swift
//  mindmail
//
//  Created by Christian Cattaneo on 10/24/25.
//

import SwiftUI

/// Personalization screen - collects user's name
/// Design: Based on aesthetic.md with secure input validation
struct PersonalizationView: View {
    @State private var name: String = ""
    @State private var errorMessage: String?
    @FocusState private var isTextFieldFocused: Bool
    
    let onContinue: (String) -> Void
    
    var body: some View {
        ZStack {
            // Background gradient
            Theme.Colors.background
                .ignoresSafeArea()
            
            VStack(spacing: Theme.Spacing.xLarge) {
                Spacer()
                
                // Icon
                Text("👋")
                    .font(.system(size: 80))
                    .padding(.bottom, Theme.Spacing.medium)
                
                // Title
                VStack(spacing: Theme.Spacing.small) {
                    Text("What should we call you?")
                        .font(.system(size: Theme.Typography.title, weight: Theme.Typography.bold))
                        .foregroundColor(Theme.Colors.textPrimary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Theme.Spacing.large)
                    
                    Text("Just your first name is perfect")
                        .font(.system(size: Theme.Typography.body, weight: Theme.Typography.regular))
                        .foregroundColor(Theme.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                }
                
                // Text input
                VStack(alignment: .leading, spacing: Theme.Spacing.xxSmall) {
                    TextField("Your name", text: $name)
                        .font(.system(size: Theme.Typography.title2, weight: Theme.Typography.medium))
                        .foregroundColor(Theme.Colors.textPrimary)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(Theme.Colors.cardBackground)
                        .cornerRadius(Theme.CornerRadius.large)
                        .shadow(
                            color: Theme.Shadow.subtle.color,
                            radius: Theme.Shadow.subtle.radius,
                            x: Theme.Shadow.subtle.x,
                            y: Theme.Shadow.subtle.y
                        )
                        .focused($isTextFieldFocused)
                        .onChange(of: name) { _, newValue in
                            // Clear error when user starts typing
                            if errorMessage != nil {
                                errorMessage = nil
                            }
                            
                            // Enforce max length in real-time
                            if newValue.count > User.maxNameLength {
                                name = String(newValue.prefix(User.maxNameLength))
                            }
                        }
                        .submitLabel(.done)
                        .onSubmit {
                            attemptContinue()
                        }
                    
                    // Character count
                    HStack {
                        if let error = errorMessage {
                            Text(error)
                                .font(.system(size: Theme.Typography.caption, weight: Theme.Typography.regular))
                                .foregroundColor(.red)
                        }
                        
                        Spacer()
                        
                        Text("\(name.count)/\(User.maxNameLength)")
                            .font(.system(size: Theme.Typography.caption, weight: Theme.Typography.regular))
                            .foregroundColor(name.count > User.maxNameLength ? .red : Theme.Colors.textSecondary)
                    }
                    .padding(.horizontal, Theme.Spacing.xxSmall)
                }
                .padding(.horizontal, Theme.Spacing.large)
                .padding(.top, Theme.Spacing.medium)
                
                Spacer()
                
                // Continue button
                Button(action: {
                    attemptContinue()
                }) {
                    Text("Continue")
                        .font(.system(size: Theme.Typography.headline, weight: Theme.Typography.semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: Theme.TouchTarget.comfortable)
                        .background(
                            isNameValid ? 
                            LinearGradient(
                                colors: [Theme.Colors.lavenderDark, Theme.Colors.softPurple],
                                startPoint: .leading,
                                endPoint: .trailing
                            ) :
                            LinearGradient(
                                colors: [Theme.Colors.textSecondary.opacity(0.5), Theme.Colors.textSecondary.opacity(0.5)],
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
                .disabled(!isNameValid)
                .padding(.horizontal, Theme.Spacing.large)
                .padding(.bottom, Theme.Spacing.xxLarge)
            }
        }
        .onAppear {
            // Auto-focus the text field
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isTextFieldFocused = true
            }
        }
    }
    
    // MARK: - Validation
    
    private var isNameValid: Bool {
        ValidationUtils.isValidName(name)
    }
    
    private func attemptContinue() {
        // Validate name
        do {
            let user = try User(name: name)
            
            // Haptic feedback
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            
            withAnimation(Theme.Animation.spring) {
                onContinue(user.name)
            }
        } catch {
            // Show error
            errorMessage = error.localizedDescription
            
            // Error haptic
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        }
    }
}

#Preview {
    PersonalizationView(onContinue: { _ in })
}


//
//  WelcomeView.swift
//  mindmail
//
//  Created by Christian Cattaneo on 10/24/25.
//

import SwiftUI

/// Welcome screen - first screen in onboarding flow
/// Design: Based on aesthetic.md with soft gradients and welcoming typography
struct WelcomeView: View {
    let onContinue: () -> Void
    
    var body: some View {
        ZStack {
            // Background gradient
            Theme.Colors.background
                .ignoresSafeArea()
            
            VStack(spacing: Theme.Spacing.xxLarge) {
                Spacer()
                
                // Logo/Icon area
                ZStack {
                    Circle()
                        .fill(Theme.Colors.lavenderDark.opacity(0.3))
                        .frame(width: 140, height: 140)
                    
                    Circle()
                        .fill(Theme.Colors.lavender.opacity(0.5))
                        .frame(width: 120, height: 120)
                    
                    Text("💌")
                        .font(.system(size: 60))
                }
                .shadow(
                    color: Theme.Shadow.medium.color,
                    radius: Theme.Shadow.medium.radius,
                    x: Theme.Shadow.medium.x,
                    y: Theme.Shadow.medium.y
                )
                
                // Title and tagline
                VStack(spacing: Theme.Spacing.small) {
                    Text("Welcome to MindMail")
                        .font(.system(size: Theme.Typography.largeTitle, weight: Theme.Typography.bold))
                        .foregroundColor(Theme.Colors.textPrimary)
                        .multilineTextAlignment(.center)
                    
                    Text("your emotional HQ for daily reflection")
                        .font(.system(size: Theme.Typography.title3, weight: Theme.Typography.regular))
                        .foregroundColor(Theme.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Theme.Spacing.large)
                }
                
                Spacer()
                
                // Continue button
                Button(action: {
                    // Haptic feedback
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                    
                    withAnimation(Theme.Animation.spring) {
                        onContinue()
                    }
                }) {
                    Text("I'm ready!")
                        .font(.system(size: Theme.Typography.headline, weight: Theme.Typography.semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: Theme.TouchTarget.comfortable)
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
                .padding(.bottom, Theme.Spacing.xxLarge)
            }
        }
    }
}

#Preview {
    WelcomeView(onContinue: {})
}


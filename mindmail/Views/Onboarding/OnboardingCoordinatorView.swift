//
//  OnboardingCoordinatorView.swift
//  mindmail
//
//  Created by Christian Cattaneo on 10/24/25.
//

import SwiftUI

/// Coordinates the onboarding flow between welcome and personalization screens
struct OnboardingCoordinatorView: View {
    @State private var viewModel = OnboardingViewModel()
    let onComplete: () -> Void
    
    var body: some View {
        ZStack {
            switch viewModel.currentStep {
            case .welcome:
                WelcomeView(onContinue: {
                    viewModel.moveToPersonalization()
                })
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
                
            case .personalization:
                PersonalizationView(onContinue: { name in
                    viewModel.completeOnboarding(with: name)
                    onComplete()
                })
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
                
            case .complete:
                // Handled by onComplete callback
                Color.clear
            }
        }
        .animation(Theme.Animation.smooth, value: viewModel.currentStep)
    }
}

#Preview {
    OnboardingCoordinatorView(onComplete: {})
}


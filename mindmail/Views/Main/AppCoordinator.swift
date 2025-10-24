//
//  AppCoordinator.swift
//  mindmail
//
//  Created by Christian Cattaneo on 10/24/25.
//

import SwiftUI

/// Main app coordinator managing onboarding and main app flow
/// Determines whether to show onboarding or main app based on user state
struct AppCoordinatorView: View {
    @State private var hasCompletedOnboarding = false
    @State private var isLoading = true
    
    private let storage = StorageService.shared
    
    var body: some View {
        ZStack {
            if isLoading {
                // Loading state
                Theme.Colors.background
                    .ignoresSafeArea()
            } else if hasCompletedOnboarding {
                // Main app
                MainTabView()
            } else {
                // Onboarding
                OnboardingCoordinatorView(onComplete: {
                    withAnimation(Theme.Animation.smooth) {
                        hasCompletedOnboarding = true
                    }
                })
            }
        }
        .onAppear {
            checkOnboardingStatus()
        }
    }
    
    private func checkOnboardingStatus() {
        hasCompletedOnboarding = storage.hasCompletedOnboarding()
        
        // Small delay for smooth appearance
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(Theme.Animation.smooth) {
                isLoading = false
            }
        }
    }
}

#Preview {
    AppCoordinatorView()
}


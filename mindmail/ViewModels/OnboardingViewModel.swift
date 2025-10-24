//
//  OnboardingViewModel.swift
//  mindmail
//
//  Created by Christian Cattaneo on 10/24/25.
//

import Foundation
import SwiftUI

/// Manages the onboarding flow and state
/// Security: Validates and persists user data securely
@MainActor
@Observable
class OnboardingViewModel {
    private let storage: StorageService
    
    // State
    enum OnboardingStep {
        case welcome
        case personalization
        case complete
    }
    
    var currentStep: OnboardingStep = .welcome
    var userName: String = ""
    
    init(storage: StorageService = .shared) {
        self.storage = storage
    }
    
    // MARK: - Navigation
    
    func moveToPersonalization() {
        currentStep = .personalization
    }
    
    func completeOnboarding(with name: String) {
        do {
            // Create and validate user
            let user = try User(name: name)
            
            // Save user to storage
            try storage.saveUser(user)
            
            // Mark onboarding as complete
            storage.completeOnboarding()
            
            // Update state
            userName = user.name
            currentStep = .complete
            
        } catch {
            // Log error (in production, would send to analytics)
            print("Error completing onboarding: \(error.localizedDescription)")
            // Note: Error is already shown in the UI via PersonalizationView validation
        }
    }
    
    /// Checks if user has completed onboarding
    func hasCompletedOnboarding() -> Bool {
        return storage.hasCompletedOnboarding()
    }
    
    /// Loads existing user if onboarding was completed
    func loadExistingUser() throws -> User? {
        return try storage.loadUser()
    }
}


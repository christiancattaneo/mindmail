//
//  JournalEntryViewModel.swift
//  mindmail
//
//  Created by Christian Cattaneo on 10/24/25.
//

import Foundation
import SwiftUI

/// Manages the 5-step journal entry flow with validation
/// Security: Validates all inputs before saving
@Observable
class JournalEntryViewModel {
    private let storage: StorageService
    
    // Entry data
    var date: Date
    var selectedMood: MoodType?
    var struggle: String = ""
    var gratitude: String = ""
    var memory: String = ""
    var lookingForward: String = ""
    
    // Flow state
    enum Step: Int, CaseIterable {
        case mood = 1
        case struggle = 2
        case gratitude = 3
        case memory = 4
        case lookingForward = 5
        
        var title: String {
            switch self {
            case .mood: return "How was today?"
            case .struggle: return "One thing that was hard today?"
            case .gratitude: return "Something you're grateful for?"
            case .memory: return "A moment to remember?"
            case .lookingForward: return "Something you're excited about?"
            }
        }
        
        var placeholder: String {
            switch self {
            case .mood: return ""
            case .struggle: return "What challenged you..."
            case .gratitude: return "Big or small..."
            case .memory: return "What made you smile..."
            case .lookingForward: return "Tomorrow or beyond..."
            }
        }
    }
    
    var currentStep: Step = .mood
    
    init(date: Date, storage: StorageService = .shared) {
        self.date = date
        self.storage = storage
        
        // Load existing entry asynchronously to avoid blocking UI
        Task {
            await loadExistingEntry()
        }
    }
    
    // MARK: - Data Loading
    
    @MainActor
    private func loadExistingEntry() async {
        do {
            if let entry = try storage.loadJournalEntry(for: date) {
                selectedMood = entry.mood
                struggle = entry.struggle
                gratitude = entry.gratitude
                memory = entry.memory
                lookingForward = entry.lookingForward
            }
        } catch {
            // Silent fail - entry just starts empty
        }
    }
    
    // MARK: - Navigation
    
    func canMoveToNextStep() -> Bool {
        switch currentStep {
        case .mood:
            return selectedMood != nil
        case .struggle:
            return ValidationUtils.isValidJournalText(struggle)
        case .gratitude:
            return ValidationUtils.isValidJournalText(gratitude)
        case .memory:
            return ValidationUtils.isValidJournalText(memory)
        case .lookingForward:
            return ValidationUtils.isValidJournalText(lookingForward)
        }
    }
    
    func moveToNextStep() {
        guard canMoveToNextStep() else { return }
        
        if let nextStep = Step(rawValue: currentStep.rawValue + 1) {
            currentStep = nextStep
        }
    }
    
    func moveToPreviousStep() {
        if let previousStep = Step(rawValue: currentStep.rawValue - 1) {
            currentStep = previousStep
        }
    }
    
    var isFirstStep: Bool {
        return currentStep == .mood
    }
    
    var isLastStep: Bool {
        return currentStep == .lookingForward
    }
    
    // MARK: - Saving
    
    func saveEntry() throws {
        guard let mood = selectedMood else {
            throw ValidationError.emptyText
        }
        
        let entry = try JournalEntry(
            date: date,
            mood: mood,
            struggle: struggle,
            gratitude: gratitude,
            memory: memory,
            lookingForward: lookingForward
        )
        
        try storage.saveJournalEntry(entry)
    }
    
    // MARK: - Character Counts
    
    func remainingCharacters(for text: String) -> Int {
        return ValidationUtils.remainingCharacters(text, maxLength: JournalEntry.maxTextLength)
    }
    
    var struggleRemaining: Int {
        remainingCharacters(for: struggle)
    }
    
    var gratitudeRemaining: Int {
        remainingCharacters(for: gratitude)
    }
    
    var memoryRemaining: Int {
        remainingCharacters(for: memory)
    }
    
    var lookingForwardRemaining: Int {
        remainingCharacters(for: lookingForward)
    }
}


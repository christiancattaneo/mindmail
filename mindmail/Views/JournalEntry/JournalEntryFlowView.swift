//
//  JournalEntryFlowView.swift
//  mindmail
//
//  Created by Christian Cattaneo on 10/24/25.
//

import SwiftUI

/// Main coordinator for the 5-step journal entry flow
/// Design: Slide-up modal with swipe-back navigation and progress tracking
struct JournalEntryFlowView: View {
    @State private var viewModel: JournalEntryViewModel
    @FocusState private var isTextFieldFocused: Bool
    @State private var showCelebration = false
    
    let onComplete: () -> Void
    
    init(date: Date, onComplete: @escaping () -> Void) {
        print("🎨 [JournalEntryFlowView] INIT called for date: \(date)")
        self._viewModel = State(initialValue: JournalEntryViewModel(date: date))
        self.onComplete = onComplete
        print("🎨 [JournalEntryFlowView] INIT complete")
    }
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Theme.Colors.softLavender, Theme.Colors.creamIvory],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Main content
            VStack(spacing: 0) {
                // Header with progress
                header
                
                // Current step content
                ScrollView {
                    VStack(spacing: Theme.Spacing.xLarge) {
                        // Question title
                        Text(viewModel.currentStep.title)
                            .font(.system(size: Theme.Typography.title, weight: Theme.Typography.bold))
                            .foregroundColor(Theme.Colors.textPrimary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, Theme.Spacing.large)
                            .padding(.top, Theme.Spacing.large)
                        
                        // Step-specific content
                        stepContent
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                    }
                }
                .gesture(
                    // Swipe back gesture
                    DragGesture(minimumDistance: 50)
                        .onEnded { value in
                            if value.translation.width > 0 && !viewModel.isFirstStep {
                                handleSwipeBack()
                            }
                        }
                )
                
                // Navigation buttons
                navigationButtons
            }
            
            // Celebration overlay
            if showCelebration {
                CelebrationView()
                    .transition(.opacity)
            }
        }
        .animation(Theme.Animation.smooth, value: viewModel.currentStep)
        .onAppear {
            print("👀 [JournalEntryFlowView] View appeared - currentStep: \(viewModel.currentStep)")
        }
        .onChange(of: viewModel.currentStep) { oldStep, newStep in
            print("🔄 [JournalEntryFlowView] Step changed from \(oldStep) to \(newStep)")
        }
    }
    
    // MARK: - Header
    
    private var header: some View {
        VStack(spacing: Theme.Spacing.small) {
            HStack {
                // Close button
                Button(action: {
                    onComplete()
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: Theme.Typography.body, weight: Theme.Typography.semibold))
                        .foregroundColor(Theme.Colors.textSecondary)
                        .frame(width: Theme.TouchTarget.minimum, height: Theme.TouchTarget.minimum)
                }
                
                Spacer()
                
                // Date
                Text(formattedDate)
                    .font(.system(size: Theme.Typography.subheadline, weight: Theme.Typography.medium))
                    .foregroundColor(Theme.Colors.textSecondary)
                
                Spacer()
                
                // Invisible spacer for centering
                Color.clear
                    .frame(width: Theme.TouchTarget.minimum, height: Theme.TouchTarget.minimum)
            }
            .padding(.horizontal, Theme.Spacing.medium)
            .padding(.top, Theme.Spacing.small)
            
            // Progress dots
            ProgressDotsView(
                currentStep: viewModel.currentStep.rawValue,
                totalSteps: JournalEntryViewModel.Step.allCases.count
            )
        }
    }
    
    // MARK: - Step Content
    
    @ViewBuilder
    private var stepContent: some View {
        switch viewModel.currentStep {
        case .mood:
            MoodSelectionView(selectedMood: $viewModel.selectedMood)
            
        case .struggle:
            JournalTextInputView(
                placeholder: viewModel.currentStep.placeholder,
                text: $viewModel.struggle,
                isFocused: $isTextFieldFocused
            )
            
        case .gratitude:
            JournalTextInputView(
                placeholder: viewModel.currentStep.placeholder,
                text: $viewModel.gratitude,
                isFocused: $isTextFieldFocused
            )
            
        case .memory:
            JournalTextInputView(
                placeholder: viewModel.currentStep.placeholder,
                text: $viewModel.memory,
                isFocused: $isTextFieldFocused
            )
            
        case .lookingForward:
            JournalTextInputView(
                placeholder: viewModel.currentStep.placeholder,
                text: $viewModel.lookingForward,
                isFocused: $isTextFieldFocused
            )
        }
    }
    
    // MARK: - Navigation Buttons
    
    private var navigationButtons: some View {
        HStack(spacing: Theme.Spacing.medium) {
            // Back button
            if !viewModel.isFirstStep {
                Button(action: {
                    handleBack()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: Theme.Typography.headline, weight: Theme.Typography.semibold))
                        .foregroundColor(Theme.Colors.textPrimary)
                        .frame(width: Theme.TouchTarget.comfortable, height: Theme.TouchTarget.comfortable)
                        .background(Theme.Colors.cardBackground)
                        .cornerRadius(Theme.CornerRadius.medium)
                }
            }
            
            // Next/Save button
            Button(action: {
                if viewModel.isLastStep {
                    handleSave()
                } else {
                    handleNext()
                }
            }) {
                Text(viewModel.isLastStep ? "Save" : "Next")
                    .font(.system(size: Theme.Typography.headline, weight: Theme.Typography.semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: Theme.TouchTarget.comfortable)
                    .background(
                        viewModel.canMoveToNextStep() ?
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
                        color: viewModel.canMoveToNextStep() ? Theme.Shadow.medium.color : Theme.Shadow.subtle.color,
                        radius: Theme.Shadow.medium.radius,
                        x: 0,
                        y: Theme.Shadow.medium.y
                    )
            }
            .disabled(!viewModel.canMoveToNextStep())
        }
        .padding(Theme.Spacing.medium)
    }
    
    // MARK: - Actions
    
    private func handleBack() {
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        withAnimation(Theme.Animation.spring) {
            viewModel.moveToPreviousStep()
        }
    }
    
    private func handleNext() {
        print("➡️ [JournalEntryFlowView] handleNext - current step: \(viewModel.currentStep)")
        let startTime = Date()
        
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        print("➡️ [JournalEntryFlowView] Unfocusing keyboard...")
        isTextFieldFocused = false
        
        print("➡️ [JournalEntryFlowView] Moving to next step...")
        withAnimation(Theme.Animation.spring) {
            viewModel.moveToNextStep()
        }
        print("➡️ [JournalEntryFlowView] New step: \(viewModel.currentStep)")
        
        // DON'T auto-focus - let user tap to focus (prevents hang)
        // The keyboard appearing causes the freeze
        print("➡️ [JournalEntryFlowView] Total time: \(Date().timeIntervalSince(startTime))s")
    }
    
    private func handleSwipeBack() {
        handleBack()
    }
    
    private func handleSave() {
        do {
            try viewModel.saveEntry()
            
            // Success haptic
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
            // Show celebration
            withAnimation(Theme.Animation.spring) {
                showCelebration = true
            }
            
            // Dismiss after celebration
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(Theme.Animation.smooth) {
                    onComplete()
                }
            }
            
        } catch {
            // Error haptic
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
            
            print("Error saving entry: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Helpers
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter.string(from: viewModel.date)
    }
}

// MARK: - Celebration View

struct CelebrationView: View {
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: Theme.Spacing.medium) {
                Text("🎉")
                    .font(.system(size: 80))
                    .scaleEffect(scale)
                
                Text("Entry Saved!")
                    .font(.system(size: Theme.Typography.title2, weight: Theme.Typography.bold))
                    .foregroundColor(.white)
                    .opacity(opacity)
            }
        }
        .onAppear {
            withAnimation(Theme.Animation.springBouncy) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }
}

#Preview {
    JournalEntryFlowView(date: Date(), onComplete: {})
}


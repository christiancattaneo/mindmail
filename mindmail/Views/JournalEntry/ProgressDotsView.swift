//
//  ProgressDotsView.swift
//  mindmail
//
//  Created by Christian Cattaneo on 10/24/25.
//

import SwiftUI

/// Progress indicator showing current step in journal entry flow
/// Design: Soft dots with smooth transitions between steps
struct ProgressDotsView: View {
    let currentStep: Int
    let totalSteps: Int
    
    var body: some View {
        HStack(spacing: Theme.Spacing.xxSmall) {
            ForEach(1...totalSteps, id: \.self) { step in
                Circle()
                    .fill(step <= currentStep ? Theme.Colors.lavenderDark : Theme.Colors.textSecondary.opacity(0.3))
                    .frame(width: 8, height: 8)
                    .scaleEffect(step == currentStep ? 1.2 : 1.0)
                    .animation(Theme.Animation.spring, value: currentStep)
            }
        }
        .padding(.vertical, Theme.Spacing.small)
    }
}

#Preview {
    VStack(spacing: 20) {
        ProgressDotsView(currentStep: 1, totalSteps: 5)
        ProgressDotsView(currentStep: 3, totalSteps: 5)
        ProgressDotsView(currentStep: 5, totalSteps: 5)
    }
}


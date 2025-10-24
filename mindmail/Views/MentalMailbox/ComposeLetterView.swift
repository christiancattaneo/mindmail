//
//  ComposeLetterViewRedesigned.swift
//  mindmail
//
//  Created by Christian Cattaneo on 10/24/25.
//

import SwiftUI

/// Compose letter view with time presets
/// Better UX for emotional wellness - quick time selections
struct ComposeLetterView: View {
    @State private var viewModel = ComposeLetterViewModel()
    @State private var selectedPreset: TimePreset = .oneMonth
    @State private var showCustomPicker = false
    @FocusState private var focusedField: Field?
    @Environment(\.dismiss) private var dismiss
    
    enum Field {
        case subject
        case body
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.Spacing.large) {
                    // Letter writing card
                    letterCard
                    
                    // When to send section
                    whenToSendSection
                    
                    // Recurrence section (only if not a long-term letter)
                    if selectedPreset == .oneWeek || selectedPreset == .oneMonth {
                        recurrenceSection
                    }
                }
                .padding(Theme.Spacing.medium)
            }
            .themeBackground()
            .navigationTitle("New Letter")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Theme.Colors.textSecondary)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: {
                        Task {
                            await handleSend()
                        }
                    }) {
                        Text("Send 💌")
                            .font(.system(size: Theme.Typography.body, weight: Theme.Typography.bold))
                            .foregroundStyle(
                                viewModel.isValid ?
                                LinearGradient(
                                    colors: [Theme.Colors.lavenderDark, Theme.Colors.cherryBlossomPink],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ) :
                                LinearGradient(
                                    colors: [Theme.Colors.textSecondary, Theme.Colors.textSecondary],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    }
                    .disabled(!viewModel.isValid)
                }
            }
            .alert("Notifications Disabled", isPresented: $viewModel.showPermissionAlert) {
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Notifications are turned off. To receive your letters, please enable notifications in Settings.")
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                if let error = viewModel.errorMessage {
                    Text(error)
                }
            }
            .sheet(isPresented: $showCustomPicker) {
                customDatePicker
            }
        }
        .onChange(of: selectedPreset) { _, newPreset in
            if newPreset == .custom {
                showCustomPicker = true
            } else {
                viewModel.scheduledDate = newPreset.futureDate()
            }
        }
    }
    
    // MARK: - Letter Card
    
    private var letterCard: some View {
        VStack(spacing: Theme.Spacing.medium) {
            // Subject
            VStack(alignment: .leading, spacing: Theme.Spacing.xSmall) {
                HStack {
                    Text("Subject")
                        .font(.system(size: Theme.Typography.subheadline, weight: Theme.Typography.bold))
                        .foregroundColor(Theme.Colors.textPrimary)
                    
                    Text("(optional)")
                        .font(.system(size: Theme.Typography.caption, weight: Theme.Typography.regular))
                        .foregroundColor(Theme.Colors.textSecondary)
                }
                
                ZStack(alignment: .leading) {
                    if viewModel.subject.isEmpty {
                        Text("A note about...")
                            .font(.system(size: Theme.Typography.body, weight: Theme.Typography.regular))
                            .foregroundColor(Theme.Colors.textSecondary.opacity(0.5))
                            .padding(.vertical, Theme.Spacing.xSmall)
                    }
                    
                    TextField("", text: $viewModel.subject)
                        .font(.system(size: Theme.Typography.body, weight: Theme.Typography.medium))
                        .foregroundColor(Theme.Colors.textPrimary)
                        .focused($focusedField, equals: .subject)
                        .padding(.vertical, Theme.Spacing.xSmall)
                }
                
                Text("\(viewModel.subjectRemaining) characters left")
                    .font(.system(size: Theme.Typography.caption, weight: Theme.Typography.regular))
                    .foregroundColor(viewModel.subjectRemaining < 10 ? .orange : Theme.Colors.textSecondary)
            }
            
            Divider()
                .background(Theme.Colors.lavender.opacity(0.3))
            
            // Message body
            VStack(alignment: .leading, spacing: Theme.Spacing.xSmall) {
                Text("Your message to future self")
                    .font(.system(size: Theme.Typography.subheadline, weight: Theme.Typography.bold))
                    .foregroundColor(Theme.Colors.textPrimary)
                
                ZStack(alignment: .topLeading) {
                    if viewModel.body.isEmpty {
                        Text("Dear Future Me,\n\nWrite something kind and encouraging...")
                            .font(.system(size: Theme.Typography.body, weight: Theme.Typography.regular))
                            .foregroundColor(Theme.Colors.textSecondary.opacity(0.5))
                            .padding(.horizontal, 5)
                            .padding(.vertical, 8)
                    }
                    
                    TextEditor(text: $viewModel.body)
                        .font(.system(size: Theme.Typography.body, weight: Theme.Typography.regular))
                        .foregroundColor(Theme.Colors.textPrimary)
                        .scrollContentBackground(.hidden)
                        .frame(minHeight: 180)
                        .focused($focusedField, equals: .body)
                }
                
                Text("\(viewModel.bodyRemaining) characters left")
                    .font(.system(size: Theme.Typography.caption, weight: Theme.Typography.regular))
                    .foregroundColor(viewModel.bodyRemaining < 50 ? .orange : Theme.Colors.textSecondary)
            }
        }
        .padding(Theme.Spacing.large)
        .background(Theme.Colors.creamIvory)
        .cornerRadius(Theme.CornerRadius.xLarge)
        .shadow(
            color: Theme.Shadow.medium.color,
            radius: Theme.Shadow.medium.radius,
            x: Theme.Shadow.medium.x,
            y: Theme.Shadow.medium.y
        )
    }
    
    // MARK: - When to Send Section
    
    private var whenToSendSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.small) {
            Text("When should we send this?")
                .font(.system(size: Theme.Typography.headline, weight: Theme.Typography.bold))
                .foregroundColor(Theme.Colors.textPrimary)
                .padding(.horizontal, Theme.Spacing.xxSmall)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Theme.Spacing.small) {
                ForEach(TimePreset.allCases.filter { $0 != .custom }) { preset in
                    TimePresetButton(
                        preset: preset,
                        isSelected: selectedPreset == preset
                    ) {
                        withAnimation(Theme.Animation.spring) {
                            selectedPreset = preset
                        }
                    }
                }
            }
            
            // Custom button (full width)
            TimePresetButton(
                preset: .custom,
                isSelected: selectedPreset == .custom,
                isFullWidth: true
            ) {
                selectedPreset = .custom
            }
        }
    }
    
    // MARK: - Recurrence Section
    
    private var recurrenceSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.small) {
            Text("Repeat this letter?")
                .font(.system(size: Theme.Typography.headline, weight: Theme.Typography.bold))
                .foregroundColor(Theme.Colors.textPrimary)
                .padding(.horizontal, Theme.Spacing.xxSmall)
            
            HStack(spacing: Theme.Spacing.small) {
                ForEach(RecurrencePattern.allCases) { pattern in
                    RecurrenceButton(
                        pattern: pattern,
                        isSelected: viewModel.recurrence == pattern
                    ) {
                        withAnimation(Theme.Animation.spring) {
                            viewModel.recurrence = pattern
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Custom Date Picker
    
    private var customDatePicker: some View {
        NavigationStack {
            VStack(spacing: Theme.Spacing.large) {
                DatePicker(
                    "Pick a date",
                    selection: $viewModel.scheduledDate,
                    in: Date()...,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .datePickerStyle(.graphical)
                .padding()
                
                Button("Done") {
                    showCustomPicker = false
                }
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
                .padding()
            }
            .themeBackground()
            .navigationTitle("Pick a Date")
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium])
    }
    
    // MARK: - Actions
    
    private func handleSend() async {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        let success = await viewModel.saveLetter()
        
        if success {
            let successGenerator = UINotificationFeedbackGenerator()
            successGenerator.notificationOccurred(.success)
            dismiss()
        } else {
            let errorGenerator = UINotificationFeedbackGenerator()
            errorGenerator.notificationOccurred(.error)
        }
    }
}

// MARK: - Time Preset Button

struct TimePresetButton: View {
    let preset: TimePreset
    let isSelected: Bool
    var isFullWidth: Bool = false
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: Theme.Spacing.xSmall) {
                Image(systemName: preset.icon)
                    .font(.system(size: 28))
                    .foregroundStyle(
                        isSelected ?
                        LinearGradient(
                            colors: [Theme.Colors.lavenderDark, Theme.Colors.cherryBlossomPink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        LinearGradient(
                            colors: [Theme.Colors.textSecondary, Theme.Colors.textSecondary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                Text(preset.label)
                    .font(.system(size: Theme.Typography.subheadline, weight: isSelected ? Theme.Typography.bold : Theme.Typography.semibold))
                    .foregroundColor(isSelected ? Theme.Colors.textPrimary : Theme.Colors.textSecondary)
                
                if !isFullWidth {
                    Text(preset.description)
                        .font(.system(size: Theme.Typography.caption, weight: Theme.Typography.regular))
                        .foregroundColor(Theme.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Theme.Spacing.medium)
            .background(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.large)
                    .fill(
                        isSelected ?
                        LinearGradient(
                            colors: [Theme.Colors.lavender.opacity(0.4), Theme.Colors.paleBlue.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        LinearGradient(
                            colors: [Theme.Colors.cardBackground, Theme.Colors.cardBackground],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.large)
                    .strokeBorder(
                        isSelected ? Theme.Colors.lavenderDark : Color.clear,
                        lineWidth: isSelected ? 2 : 0
                    )
            )
            .shadow(
                color: isSelected ? Theme.Shadow.medium.color : Theme.Shadow.subtle.color,
                radius: isSelected ? Theme.Shadow.medium.radius : Theme.Shadow.subtle.radius,
                x: 0,
                y: isSelected ? Theme.Shadow.medium.y : Theme.Shadow.subtle.y
            )
        }
        .animation(Theme.Animation.spring, value: isSelected)
    }
}

// MARK: - Recurrence Button

struct RecurrenceButton: View {
    let pattern: RecurrencePattern
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Theme.Spacing.xSmall) {
                Image(systemName: pattern.icon)
                    .font(.system(size: 18))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(pattern.label)
                        .font(.system(size: Theme.Typography.subheadline, weight: Theme.Typography.bold))
                    
                    Text(pattern.description)
                        .font(.system(size: Theme.Typography.caption, weight: Theme.Typography.regular))
                }
            }
            .foregroundColor(isSelected ? .white : Theme.Colors.textPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(Theme.Spacing.medium)
            .background(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                    .fill(
                        isSelected ?
                        LinearGradient(
                            colors: [Theme.Colors.lavenderDark, Theme.Colors.softPurple],
                            startPoint: .leading,
                            endPoint: .trailing
                        ) :
                        LinearGradient(
                            colors: [Theme.Colors.cardBackground, Theme.Colors.cardBackground],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                    .strokeBorder(
                        isSelected ? Color.clear : Theme.Colors.lavender,
                        lineWidth: 1
                    )
            )
        }
        .animation(Theme.Animation.spring, value: isSelected)
    }
}

#Preview {
    ComposeLetterView()
}


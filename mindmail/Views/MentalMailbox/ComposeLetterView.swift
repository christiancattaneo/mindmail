//
//  ComposeLetterView.swift
//  mindmail
//
//  Created by Christian Cattaneo on 10/24/25.
//

import SwiftUI

/// Compose letter view with paper-like interface
/// Design: Clean, paper-inspired UI with soft shadows and gentle animations
struct ComposeLetterView: View {
    @State private var viewModel = ComposeLetterViewModel()
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
                    // Paper-like letter card
                    VStack(spacing: Theme.Spacing.medium) {
                        // Subject line
                        VStack(alignment: .leading, spacing: Theme.Spacing.xSmall) {
                            Text("Subject (optional)")
                                .font(.system(size: Theme.Typography.subheadline, weight: Theme.Typography.semibold))
                                .foregroundColor(Theme.Colors.textPrimary)
                            
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
                                    .onChange(of: viewModel.subject) { _, newValue in
                                        if newValue.count > Letter.maxSubjectLength {
                                            viewModel.subject = String(newValue.prefix(Letter.maxSubjectLength))
                                        }
                                    }
                            }
                            
                            Text("\(viewModel.subjectRemaining) characters remaining")
                                .font(.system(size: Theme.Typography.caption, weight: Theme.Typography.regular))
                                .foregroundColor(Theme.Colors.textSecondary)
                        }
                        
                        Divider()
                            .background(Theme.Colors.textSecondary.opacity(0.2))
                        
                        // Letter body
                        VStack(alignment: .leading, spacing: Theme.Spacing.xSmall) {
                            Text("Your message to future self")
                                .font(.system(size: Theme.Typography.subheadline, weight: Theme.Typography.semibold))
                                .foregroundColor(Theme.Colors.textPrimary)
                            
                            ZStack(alignment: .topLeading) {
                                if viewModel.body.isEmpty {
                                    Text("Dear Future Me,\n\nWrite your thoughts here...")
                                        .font(.system(size: Theme.Typography.body, weight: Theme.Typography.regular))
                                        .foregroundColor(Theme.Colors.textSecondary.opacity(0.5))
                                        .padding(.horizontal, 5)
                                        .padding(.vertical, 8)
                                }
                                
                                TextEditor(text: $viewModel.body)
                                    .font(.system(size: Theme.Typography.body, weight: Theme.Typography.regular))
                                    .foregroundColor(Theme.Colors.textPrimary)
                                    .scrollContentBackground(.hidden)
                                    .frame(minHeight: 200)
                                    .focused($focusedField, equals: .body)
                                    .onChange(of: viewModel.body) { _, newValue in
                                        if newValue.count > Letter.maxBodyLength {
                                            viewModel.body = String(newValue.prefix(Letter.maxBodyLength))
                                        }
                                    }
                            }
                            
                            Text("\(viewModel.bodyRemaining) characters remaining")
                                .font(.system(size: Theme.Typography.caption, weight: Theme.Typography.regular))
                                .foregroundColor(viewModel.bodyRemaining < 100 ? .orange : Theme.Colors.textSecondary)
                        }
                    }
                    .padding(Theme.Spacing.large)
                    .background(Theme.Colors.creamIvory)
                    .cornerRadius(Theme.CornerRadius.large)
                    .shadow(
                        color: Theme.Shadow.medium.color,
                        radius: Theme.Shadow.medium.radius,
                        x: Theme.Shadow.medium.x,
                        y: Theme.Shadow.medium.y
                    )
                    
                    // Scheduling section
                    VStack(spacing: Theme.Spacing.medium) {
                        // Date and time picker
                        VStack(alignment: .leading, spacing: Theme.Spacing.xSmall) {
                            Text("Deliver on")
                                .font(.system(size: Theme.Typography.subheadline, weight: Theme.Typography.semibold))
                                .foregroundColor(Theme.Colors.textPrimary)
                            
                            DatePicker(
                                "",
                                selection: $viewModel.scheduledDate,
                                in: Date()...,
                                displayedComponents: [.date, .hourAndMinute]
                            )
                            .datePickerStyle(.compact)
                            .labelsHidden()
                        }
                        .padding()
                        .background(Theme.Colors.cardBackground)
                        .cornerRadius(Theme.CornerRadius.medium)
                        
                        // Recurrence selector
                        VStack(alignment: .leading, spacing: Theme.Spacing.xSmall) {
                            Text("Repeat")
                                .font(.system(size: Theme.Typography.subheadline, weight: Theme.Typography.semibold))
                                .foregroundColor(Theme.Colors.textPrimary)
                            
                            Picker("Recurrence", selection: $viewModel.recurrence) {
                                ForEach(RecurrencePattern.allCases) { pattern in
                                    Text(pattern.label).tag(pattern)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                        .padding()
                        .background(Theme.Colors.cardBackground)
                        .cornerRadius(Theme.CornerRadius.medium)
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
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Send to Future Me") {
                        Task {
                            await handleSend()
                        }
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
        }
    }
    
    // MARK: - Actions
    
    private func handleSend() async {
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        let success = await viewModel.saveLetter()
        
        if success {
            // Success haptic
            let successGenerator = UINotificationFeedbackGenerator()
            successGenerator.notificationOccurred(.success)
            
            dismiss()
        } else {
            // Error haptic
            let errorGenerator = UINotificationFeedbackGenerator()
            errorGenerator.notificationOccurred(.error)
        }
    }
}

#Preview {
    ComposeLetterView()
}


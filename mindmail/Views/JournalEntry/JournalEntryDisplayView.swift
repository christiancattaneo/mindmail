//
//  JournalEntryDisplayView.swift
//  mindmail
//
//  Created by Christian Cattaneo on 10/24/25.
//

import SwiftUI

/// Beautiful display view for saved journal entries with inline editing
/// Tap any section to edit it aesthetically
struct JournalEntryDisplayView: View {
    let entry: JournalEntry
    let onClose: () -> Void
    
    @State private var selectedMood: MoodType
    @State private var struggle: String
    @State private var gratitude: String
    @State private var memory: String
    @State private var lookingForward: String
    @State private var showMoodPicker = false
    @State private var editingField: EditField?
    @State private var hasChanges = false
    
    private let storage = StorageService.shared
    
    enum EditField: Identifiable {
        case struggle
        case gratitude
        case memory
        case lookingForward
        
        var id: String {
            switch self {
            case .struggle: return "struggle"
            case .gratitude: return "gratitude"
            case .memory: return "memory"
            case .lookingForward: return "lookingForward"
            }
        }
    }
    
    init(entry: JournalEntry, onClose: @escaping () -> Void) {
        self.entry = entry
        self.onClose = onClose
        self._selectedMood = State(initialValue: entry.mood)
        self._struggle = State(initialValue: entry.struggle)
        self._gratitude = State(initialValue: entry.gratitude)
        self._memory = State(initialValue: entry.memory)
        self._lookingForward = State(initialValue: entry.lookingForward)
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        return formatter.string(from: entry.date)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.Spacing.large) {
                    // Mood Header
                    moodHeader
                    
                    // Entry Sections
                    entrySection(
                        title: "One Struggle",
                        icon: "cloud.rain.fill",
                        color: Theme.Colors.skyBlue,
                        content: struggle
                    )
                    
                    entrySection(
                        title: "Gratitude",
                        icon: "heart.fill",
                        color: Theme.Colors.cherryBlossomPink,
                        content: gratitude
                    )
                    
                    entrySection(
                        title: "Memory to Keep",
                        icon: "star.fill",
                        color: Theme.Colors.peach,
                        content: memory
                    )
                    
                    entrySection(
                        title: "Looking Forward",
                        icon: "sparkles",
                        color: Theme.Colors.lavenderDark,
                        content: lookingForward
                    )
                    
                    Spacer(minLength: Theme.Spacing.xxLarge)
                }
                .padding(Theme.Spacing.large)
            }
            .background(
                LinearGradient(
                    colors: [Theme.Colors.softLavender, Theme.Colors.creamIvory],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        onClose()
                    }
                    .foregroundColor(Theme.Colors.textSecondary)
                }
                
                ToolbarItem(placement: .principal) {
                    Text(formattedDate)
                        .font(.system(size: Theme.Typography.subheadline, weight: Theme.Typography.semibold))
                        .foregroundColor(Theme.Colors.textSecondary)
                }
                
                ToolbarItem(placement: .primaryAction) {
                    if hasChanges {
                        Button("Save") {
                            saveChanges()
                        }
                        .font(.system(size: Theme.Typography.body, weight: Theme.Typography.bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Theme.Colors.lavenderDark, Theme.Colors.cherryBlossomPink],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    }
                }
            }
            .onChange(of: selectedMood) { _, _ in hasChanges = true }
            .onChange(of: struggle) { _, _ in hasChanges = true }
            .onChange(of: gratitude) { _, _ in hasChanges = true }
            .onChange(of: memory) { _, _ in hasChanges = true }
            .onChange(of: lookingForward) { _, _ in hasChanges = true }
            .sheet(isPresented: $showMoodPicker) {
                moodPickerSheet
            }
            .sheet(item: $editingField) { field in
                editFieldSheet(for: field)
            }
        }
    }
    
    // MARK: - Mood Header (Tappable)
    
    private var moodHeader: some View {
        Button(action: {
            showMoodPicker = true
        }) {
            VStack(spacing: Theme.Spacing.medium) {
                // Large mood emoji with glow
                ZStack {
                    Circle()
                        .fill(Theme.colorForMood(selectedMood).opacity(0.2))
                        .frame(width: 100, height: 100)
                    
                    Text(selectedMood.emoji)
                        .font(.system(size: 60))
                }
                
                // Mood label
                HStack(spacing: 4) {
                    Text(selectedMood.label)
                        .font(.system(size: Theme.Typography.title2, weight: Theme.Typography.bold))
                        .foregroundColor(Theme.Colors.textPrimary)
                    
                    Image(systemName: "pencil.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(Theme.Colors.lavenderDark.opacity(0.6))
                }
                
                Text("How you felt · Tap to change")
                    .font(.system(size: Theme.Typography.caption, weight: Theme.Typography.regular))
                    .foregroundColor(Theme.Colors.textSecondary)
            }
            .padding(.top, Theme.Spacing.medium)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Entry Section (Tappable)
    
    private func entrySection(title: String, icon: String, color: Color, content: String) -> some View {
        Button(action: {
            editingField = fieldForTitle(title)
        }) {
            VStack(alignment: .leading, spacing: Theme.Spacing.small) {
                // Section header
                HStack(spacing: Theme.Spacing.xSmall) {
                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundColor(color)
                    
                    Text(title)
                        .font(.system(size: Theme.Typography.headline, weight: Theme.Typography.bold))
                        .foregroundColor(Theme.Colors.textPrimary)
                    
                    Spacer()
                    
                    Image(systemName: "pencil.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(Theme.Colors.textSecondary.opacity(0.5))
                }
                
                // Content card
                Text(content)
                    .font(.system(size: Theme.Typography.body, weight: Theme.Typography.regular))
                    .foregroundColor(Theme.Colors.textPrimary)
                    .lineSpacing(6)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(Theme.Spacing.medium)
                    .background(Theme.Colors.cardBackground)
                    .cornerRadius(Theme.CornerRadius.large)
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.CornerRadius.large)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [color.opacity(0.3), color.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Mood Picker Sheet
    
    private var moodPickerSheet: some View {
        NavigationStack {
            VStack(spacing: Theme.Spacing.large) {
                Text("How are you feeling?")
                    .font(.system(size: Theme.Typography.title2, weight: Theme.Typography.bold))
                    .foregroundColor(Theme.Colors.textPrimary)
                    .padding(.top, Theme.Spacing.large)
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: Theme.Spacing.medium) {
                    ForEach(MoodType.allCases) { mood in
                        MoodButton(mood: mood, isSelected: selectedMood == mood) {
                            selectedMood = mood
                            showMoodPicker = false
                            
                            let generator = UIImpactFeedbackGenerator(style: .medium)
                            generator.impactOccurred()
                        }
                    }
                }
                .padding(.horizontal, Theme.Spacing.large)
                
                Spacer()
            }
            .background(Theme.Colors.softLavender)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showMoodPicker = false
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
    
    // MARK: - Edit Field Sheet
    
    private func editFieldSheet(for field: EditField) -> some View {
        NavigationStack {
            VStack(spacing: Theme.Spacing.medium) {
                Text(titleForField(field))
                    .font(.system(size: Theme.Typography.title3, weight: Theme.Typography.bold))
                    .foregroundColor(Theme.Colors.textPrimary)
                    .padding(.top, Theme.Spacing.large)
                
                TextEditor(text: bindingForField(field))
                    .font(.system(size: Theme.Typography.body, weight: Theme.Typography.regular))
                    .foregroundColor(Theme.Colors.textPrimary)
                    .padding()
                    .frame(height: 200)
                    .background(Theme.Colors.cardBackground)
                    .cornerRadius(Theme.CornerRadius.large)
                    .padding(.horizontal)
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            Spacer()
                            Button("Done") {
                                editingField = nil
                            }
                            .foregroundColor(Theme.Colors.lavenderDark)
                        }
                    }
                
                Text("\(charactersRemaining(for: field)) characters remaining")
                    .font(.system(size: Theme.Typography.caption))
                    .foregroundColor(Theme.Colors.textSecondary)
                
                Button("Done") {
                    editingField = nil
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
                
                Spacer()
            }
            .background(Theme.Colors.softLavender)
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium, .large])
    }
    
    // MARK: - Helpers
    
    private func fieldForTitle(_ title: String) -> EditField? {
        switch title {
        case "One Struggle": return .struggle
        case "Gratitude": return .gratitude
        case "Memory to Keep": return .memory
        case "Looking Forward": return .lookingForward
        default: return nil
        }
    }
    
    private func titleForField(_ field: EditField) -> String {
        switch field {
        case .struggle: return "One thing that was hard today?"
        case .gratitude: return "Something you're grateful for?"
        case .memory: return "A moment to remember?"
        case .lookingForward: return "Something you're excited about?"
        }
    }
    
    private func bindingForField(_ field: EditField) -> Binding<String> {
        switch field {
        case .struggle: return $struggle
        case .gratitude: return $gratitude
        case .memory: return $memory
        case .lookingForward: return $lookingForward
        }
    }
    
    private func charactersRemaining(for field: EditField) -> Int {
        let text = switch field {
        case .struggle: struggle
        case .gratitude: gratitude
        case .memory: memory
        case .lookingForward: lookingForward
        }
        return JournalEntry.maxTextLength - text.count
    }
    
    // MARK: - Save
    
    private func saveChanges() {
        do {
            let updatedEntry = try JournalEntry(
                id: entry.id,
                date: entry.date,
                mood: selectedMood,
                struggle: struggle,
                gratitude: gratitude,
                memory: memory,
                lookingForward: lookingForward,
                createdAt: entry.createdAt
            )
            
            try storage.saveJournalEntry(updatedEntry)
            
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
            hasChanges = false
            onClose()
        } catch {
            print("❌ Error saving: \(error)")
            
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        }
    }
}


#Preview {
    let entry = try! JournalEntry(
        date: Date(),
        mood: .awesome,
        struggle: "Long day at work with many meetings",
        gratitude: "My supportive team and good coffee",
        memory: "Lunch with a friend in the park",
        lookingForward: "Weekend plans and time to rest"
    )
    
    JournalEntryDisplayView(
        entry: entry,
        onClose: {}
    )
}


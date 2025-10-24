//
//  MainTabView.swift
//  mindmail
//
//  Created by Christian Cattaneo on 10/24/25.
//

import SwiftUI

/// Main tab bar view with Reflect and Mental Mailbox tabs
/// Design: Clean tab bar with aesthetic icons and smooth transitions
struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var selectedDate: Date?
    @State private var selectedEntry: JournalEntry?
    @State private var showEditMode = false
    @State private var refreshCalendar = false
    
    private var showJournalEntry: Binding<Bool> {
        Binding(
            get: { selectedDate != nil },
            set: { if !$0 { selectedDate = nil; selectedEntry = nil; showEditMode = false } }
        )
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Reflect Tab (Calendar + Journal)
            NavigationStack {
                CalendarView(onDateSelected: handleDateSelection)
                    .id(refreshCalendar)
            }
            .tabItem {
                Label("Reflect", systemImage: selectedTab == 0 ? "calendar.circle.fill" : "calendar.circle")
            }
            .tag(0)
            
            // Mental Mailbox Tab
            LetterInboxView()
                .tabItem {
                    Label("Mailbox", systemImage: selectedTab == 1 ? "envelope.circle.fill" : "envelope.circle")
                }
                .tag(1)
        }
        .tint(Theme.Colors.lavenderDark)
        .sheet(isPresented: showJournalEntry, onDismiss: handleSheetDismiss) {
            if let date = selectedDate {
                if showEditMode {
                    // Edit mode (new entry or editing)
                    JournalEntryFlowView(date: date, onComplete: handleJournalComplete)
                        .onAppear {
                            print("✅ [MainTabView] JournalEntryFlowView appeared (edit mode)")
                        }
                } else if let entry = selectedEntry {
                    // Display mode (viewing existing entry with inline editing)
                    JournalEntryDisplayView(entry: entry, onClose: handleJournalComplete)
                        .onAppear {
                            print("👁️ [MainTabView] JournalEntryDisplayView appeared (inline edit mode)")
                        }
                }
            }
        }
    }
    
    // MARK: - Actions
    
    private func handleDateSelection(date: Date, entry: JournalEntry?) {
        print("📲 [MainTabView] Date selected: \(date), hasEntry: \(entry != nil)")
        selectedDate = date
        selectedEntry = entry
        showEditMode = (entry == nil) // Edit mode if no entry, display mode if has entry
        print("📲 [MainTabView] selectedDate: \(String(describing: selectedDate)), editMode: \(showEditMode)")
    }
    
    private func handleSheetDismiss() {
        print("🚪 [MainTabView] Sheet dismissed, refreshing calendar")
        selectedDate = nil
        refreshCalendar.toggle()
    }
    
    private func handleJournalComplete() {
        print("🏁 [MainTabView] Journal entry completed")
        selectedDate = nil
    }
}

#Preview {
    MainTabView()
}



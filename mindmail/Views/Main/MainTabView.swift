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
    @State private var refreshCalendar = false
    
    private var showJournalEntry: Binding<Bool> {
        Binding(
            get: { selectedDate != nil },
            set: { if !$0 { selectedDate = nil } }
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
                JournalEntryFlowView(date: date, onComplete: handleJournalComplete)
                    .onAppear {
                        print("✅ [MainTabView] JournalEntryFlowView appeared with date: \(date)")
                    }
            }
        }
    }
    
    // MARK: - Actions
    
    private func handleDateSelection(date: Date, entry: JournalEntry?) {
        print("📲 [MainTabView] Date selected: \(date), hasEntry: \(entry != nil)")
        selectedDate = date
        print("📲 [MainTabView] selectedDate is now: \(String(describing: selectedDate))")
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



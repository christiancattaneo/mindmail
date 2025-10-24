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
    @State private var showJournalEntry = false
    @State private var selectedDate: Date?
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Reflect Tab (Calendar + Journal)
            NavigationStack {
                CalendarView(onDateSelected: { date, entry in
                    selectedDate = date
                    showJournalEntry = true
                })
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
        .sheet(isPresented: $showJournalEntry) {
            if let date = selectedDate {
                JournalEntryFlowView(date: date) {
                    showJournalEntry = false
                    // Reload calendar to show new entry
                }
            }
        }
    }
}

#Preview {
    MainTabView()
}


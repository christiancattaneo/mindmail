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
    @State private var refreshCalendar = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Reflect Tab (Calendar + Journal)
            NavigationStack {
                CalendarView(onDateSelected: { date, entry in
                    print("📅 Date selected: \(date)")
                    print("📝 Entry exists: \(entry != nil)")
                    selectedDate = date
                    DispatchQueue.main.async {
                        showJournalEntry = true
                    }
                })
                .id(refreshCalendar) // Force refresh when this changes
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
            // Reload calendar when sheet dismisses
            refreshCalendar.toggle()
            print("📋 Journal entry sheet dismissed")
        } content: {
            if let date = selectedDate {
                print("🎨 Rendering JournalEntryFlowView for date: \(date)")
                JournalEntryFlowView(date: date) {
                    print("✅ Journal entry completed")
                    showJournalEntry = false
                }
            } else {
                print("❌ ERROR: selectedDate is nil!")
                Color.red // Debug: show red if date is nil
            }
        }
    }
}

#Preview {
    MainTabView()
}


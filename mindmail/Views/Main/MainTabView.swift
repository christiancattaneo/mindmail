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
        .sheet(isPresented: $showJournalEntry, onDismiss: handleSheetDismiss) {
            Group {
                if let date = selectedDate {
                    JournalEntryFlowView(date: date, onComplete: handleJournalComplete)
                        .onAppear {
                            print("✅ [MainTabView] JournalEntryFlowView appeared with date: \(date)")
                        }
                } else {
                    VStack(spacing: Theme.Spacing.medium) {
                        Text("❌ Error: No date selected")
                            .foregroundColor(.red)
                            .font(.headline)
                        Text("selectedDate is nil")
                            .foregroundColor(.gray)
                            .font(.caption)
                        Button("Close") {
                            showJournalEntry = false
                        }
                    }
                    .padding()
                    .onAppear {
                        print("❌ [MainTabView] ERROR VIEW appeared - selectedDate is nil!")
                    }
                }
            }
        }
    }
    
    // MARK: - Actions
    
    private func handleDateSelection(date: Date, entry: JournalEntry?) {
        print("📲 [MainTabView] Date selected: \(date), hasEntry: \(entry != nil)")
        selectedDate = date
        
        // Small delay to ensure state is fully updated before showing sheet
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            print("📲 [MainTabView] Showing sheet with selectedDate: \(String(describing: self.selectedDate))")
            showJournalEntry = true
        }
    }
    
    private func handleSheetDismiss() {
        print("🚪 [MainTabView] Sheet dismissed, refreshing calendar")
        refreshCalendar.toggle()
    }
    
    private func handleJournalComplete() {
        print("🏁 [MainTabView] Journal entry completed")
        showJournalEntry = false
    }
}

#Preview {
    MainTabView()
}



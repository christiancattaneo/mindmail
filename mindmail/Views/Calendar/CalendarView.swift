//
//  CalendarView.swift
//  mindmail
//
//  Created by Christian Cattaneo on 10/24/25.
//

import SwiftUI

/// Main calendar view showing month grid with journal entries
/// Design: Based on aesthetic.md with soft rounded squares and emoji indicators
struct CalendarView: View {
    @State private var viewModel = CalendarViewModel()
    @State private var userName: String = ""
    let onDateSelected: (Date, JournalEntry?) -> Void
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: Theme.Spacing.xSmall), count: 7)
    private let weekdays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    var body: some View {
        VStack(spacing: Theme.Spacing.medium) {
            // Greeting header
            greetingHeader
            
            // Month header with navigation
            monthHeader
            
            // Weekday labels
            weekdayLabels
            
            // Calendar grid
            calendarGrid
            
            Spacer()
        }
        .padding(Theme.Spacing.medium)
        .themeBackground()
        .onAppear {
            loadUserName()
        }
    }
    
    // MARK: - Greeting Header
    
    private var greetingHeader: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xxxSmall) {
            Text(greeting)
                .font(.system(size: Theme.Typography.largeTitle, weight: Theme.Typography.bold))
                .foregroundColor(Theme.Colors.textPrimary)
            
            Text("Let's reflect on your journey")
                .font(.system(size: Theme.Typography.body, weight: Theme.Typography.regular))
                .foregroundColor(Theme.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Theme.Spacing.xSmall)
        .padding(.bottom, Theme.Spacing.small)
    }
    
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        let timeGreeting = switch hour {
        case 0..<12: "Good morning"
        case 12..<17: "Good afternoon"
        default: "Good evening"
        }
        
        if !userName.isEmpty {
            return "\(timeGreeting), \(userName)"
        } else {
            return timeGreeting
        }
    }
    
    private func loadUserName() {
        if let user = try? StorageService.shared.loadUser() {
            userName = user.name
        }
    }
    
    // MARK: - Month Header
    
    private var monthHeader: some View {
        HStack(spacing: Theme.Spacing.medium) {
            // Previous month button
            Button(action: {
                withAnimation(Theme.Animation.spring) {
                    viewModel.moveToPreviousMonth()
                }
            }) {
                Image(systemName: "chevron.left.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Theme.Colors.lavenderDark, Theme.Colors.softPurple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: Theme.TouchTarget.minimum, height: Theme.TouchTarget.minimum)
            }
            
            Spacer()
            
            // Month and year with card background
            VStack(spacing: Theme.Spacing.xxxSmall) {
                Text(viewModel.monthYearString)
                    .font(.system(size: Theme.Typography.title2, weight: Theme.Typography.bold))
                    .foregroundColor(Theme.Colors.textPrimary)
                
                // Today button
                Button(action: {
                    withAnimation(Theme.Animation.spring) {
                        viewModel.moveToToday()
                    }
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "star.circle.fill")
                            .font(.system(size: 10))
                        Text("Today")
                            .font(.system(size: Theme.Typography.caption, weight: Theme.Typography.semibold))
                    }
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Theme.Colors.lavenderDark, Theme.Colors.cherryBlossomPink],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .padding(.horizontal, Theme.Spacing.small)
                    .padding(.vertical, Theme.Spacing.xxxSmall)
                    .background(Theme.Colors.lavender.opacity(0.3))
                    .cornerRadius(Theme.CornerRadius.small)
                }
            }
            
            Spacer()
            
            // Next month button
            Button(action: {
                withAnimation(Theme.Animation.spring) {
                    viewModel.moveToNextMonth()
                }
            }) {
                Image(systemName: "chevron.right.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Theme.Colors.lavenderDark, Theme.Colors.softPurple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: Theme.TouchTarget.minimum, height: Theme.TouchTarget.minimum)
            }
        }
        .padding(.horizontal, Theme.Spacing.xSmall)
        .padding(.vertical, Theme.Spacing.xSmall)
    }
    
    // MARK: - Weekday Labels
    
    private var weekdayLabels: some View {
        LazyVGrid(columns: columns, spacing: Theme.Spacing.xSmall) {
            ForEach(weekdays, id: \.self) { day in
                Text(day)
                    .font(.system(size: Theme.Typography.caption, weight: Theme.Typography.bold))
                    .foregroundColor(Theme.Colors.textSecondary)
                    .frame(maxWidth: .infinity)
                    .textCase(.uppercase)
            }
        }
        .padding(.horizontal, Theme.Spacing.xSmall)
        .padding(.bottom, Theme.Spacing.xxxSmall)
    }
    
    // MARK: - Calendar Grid
    
    private var calendarGrid: some View {
        LazyVGrid(columns: columns, spacing: Theme.Spacing.xSmall) {
            ForEach(Array(viewModel.datesForCalendarGrid().enumerated()), id: \.offset) { index, date in
                if let date = date {
                    DayCell(
                        date: date,
                        entry: viewModel.entry(for: date),
                        isToday: viewModel.isToday(date),
                        isFuture: viewModel.isFuture(date),
                        isSelected: viewModel.isSelected(date)
                    ) {
                        handleDateTap(date)
                    }
                } else {
                    // Empty padding cell
                    Color.clear
                        .aspectRatio(1, contentMode: .fit)
                }
            }
        }
        .padding(.horizontal, Theme.Spacing.xSmall)
        .padding(.vertical, Theme.Spacing.xxSmall)
        .background(
            RoundedRectangle(cornerRadius: Theme.CornerRadius.xLarge)
                .fill(Theme.Colors.cardBackground)
                .shadow(
                    color: Theme.Shadow.subtle.color,
                    radius: Theme.Shadow.subtle.radius,
                    x: 0,
                    y: Theme.Shadow.subtle.y
                )
        )
        .padding(.horizontal, Theme.Spacing.xSmall)
        .gesture(
            DragGesture(minimumDistance: 50)
                .onEnded { value in
                    handleSwipe(value)
                }
        )
    }
    
    // MARK: - Swipe Gesture
    
    private func handleSwipe(_ value: DragGesture.Value) {
        let horizontalAmount = value.translation.width
        let verticalAmount = value.translation.height
        
        // Only handle horizontal swipes
        if abs(horizontalAmount) > abs(verticalAmount) {
            // Haptic feedback
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            
            withAnimation(Theme.Animation.spring) {
                if horizontalAmount < 0 {
                    // Swipe left - next month
                    viewModel.moveToNextMonth()
                } else {
                    // Swipe right - previous month
                    viewModel.moveToPreviousMonth()
                }
            }
        }
    }
    
    // MARK: - Actions
    
    private func handleDateTap(_ date: Date) {
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        withAnimation(Theme.Animation.spring) {
            let entry = viewModel.selectDate(date)
            onDateSelected(date, entry)
        }
    }
}

// MARK: - Day Cell

struct DayCell: View {
    let date: Date
    let entry: JournalEntry?
    let isToday: Bool
    let isFuture: Bool
    let isSelected: Bool
    let onTap: () -> Void
    
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: Theme.Spacing.xxxSmall) {
                // Day number
                Text(dayNumber)
                    .font(.system(size: Theme.Typography.subheadline, weight: isToday ? Theme.Typography.bold : Theme.Typography.medium))
                    .foregroundColor(isFuture ? Theme.Colors.textSecondary.opacity(0.5) : Theme.Colors.textPrimary)
                
                // Mood emoji or indicator
                if let entry = entry {
                    Text(entry.mood.emoji)
                        .font(.system(size: 22))
                } else {
                    Circle()
                        .fill(isFuture ? Color.clear : Theme.Colors.textSecondary.opacity(0.2))
                        .frame(width: 5, height: 5)
                }
            }
            .frame(maxWidth: .infinity)
            .aspectRatio(1, contentMode: .fit)
            .background(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.large)
                    .fill(backgroundColor)
            )
            .overlay(
                // Static highlight for today - NO ANIMATION to prevent bouncing
                RoundedRectangle(cornerRadius: Theme.CornerRadius.large)
                    .strokeBorder(borderColor, lineWidth: isToday ? 2.5 : 0)
            )
        }
        .disabled(isFuture)
    }
    
    private var backgroundColor: Color {
        if isSelected {
            return Theme.Colors.lavenderDark.opacity(0.3)
        } else if entry != nil {
            return Theme.Colors.lavender.opacity(0.2)
        } else {
            return Theme.Colors.cardBackground
        }
    }
    
    private var borderColor: Color {
        if isToday {
            // Subtle gradient effect on border
            return Theme.Colors.cherryBlossomPink
        } else if isSelected {
            return Theme.Colors.lavenderDark.opacity(0.5)
        } else {
            return Color.clear
        }
    }
}

#Preview {
    CalendarView(onDateSelected: { _, _ in })
}


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
    let onDateSelected: (Date, JournalEntry?) -> Void
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: Theme.Spacing.xxSmall), count: 7)
    private let weekdays = ["S", "M", "T", "W", "T", "F", "S"]
    
    var body: some View {
        VStack(spacing: Theme.Spacing.medium) {
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
    }
    
    // MARK: - Month Header
    
    private var monthHeader: some View {
        HStack {
            // Previous month button
            Button(action: {
                withAnimation(Theme.Animation.spring) {
                    viewModel.moveToPreviousMonth()
                }
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: Theme.Typography.title3, weight: Theme.Typography.semibold))
                    .foregroundColor(Theme.Colors.textPrimary)
                    .frame(width: Theme.TouchTarget.minimum, height: Theme.TouchTarget.minimum)
            }
            
            Spacer()
            
            // Month and year
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
                    Text("Today")
                        .font(.system(size: Theme.Typography.caption, weight: Theme.Typography.medium))
                        .foregroundColor(Theme.Colors.lavenderDark)
                }
            }
            
            Spacer()
            
            // Next month button
            Button(action: {
                withAnimation(Theme.Animation.spring) {
                    viewModel.moveToNextMonth()
                }
            }) {
                Image(systemName: "chevron.right")
                    .font(.system(size: Theme.Typography.title3, weight: Theme.Typography.semibold))
                    .foregroundColor(Theme.Colors.textPrimary)
                    .frame(width: Theme.TouchTarget.minimum, height: Theme.TouchTarget.minimum)
            }
        }
        .padding(.horizontal, Theme.Spacing.xSmall)
    }
    
    // MARK: - Weekday Labels
    
    private var weekdayLabels: some View {
        LazyVGrid(columns: columns, spacing: Theme.Spacing.xxSmall) {
            ForEach(weekdays, id: \.self) { day in
                Text(day)
                    .font(.system(size: Theme.Typography.footnote, weight: Theme.Typography.semibold))
                    .foregroundColor(Theme.Colors.textSecondary)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, Theme.Spacing.xSmall)
    }
    
    // MARK: - Calendar Grid
    
    private var calendarGrid: some View {
        LazyVGrid(columns: columns, spacing: Theme.Spacing.xxSmall) {
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
    
    @State private var pulseScale: CGFloat = 1.0
    
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
                        .font(.system(size: 20))
                } else {
                    Circle()
                        .fill(isFuture ? Color.clear : Theme.Colors.textSecondary.opacity(0.2))
                        .frame(width: 4, height: 4)
                }
            }
            .frame(maxWidth: .infinity)
            .aspectRatio(1, contentMode: .fit)
            .background(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                    .fill(backgroundColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                    .strokeBorder(borderColor, lineWidth: isToday ? 2 : 0)
            )
            .scaleEffect(isToday ? pulseScale : 1.0)
        }
        .disabled(isFuture)
        .onAppear {
            if isToday {
                withAnimation(
                    .easeInOut(duration: 1.5)
                    .repeatForever(autoreverses: true)
                ) {
                    pulseScale = 1.08
                }
            }
        }
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
            return Theme.Colors.lavenderDark
        } else {
            return Color.clear
        }
    }
}

#Preview {
    CalendarView(onDateSelected: { _, _ in })
}


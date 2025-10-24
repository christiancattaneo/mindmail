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
    @State private var showMonthYearPicker = false
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
        .sheet(isPresented: $showMonthYearPicker) {
            monthYearPickerView
        }
    }
    
    // MARK: - Greeting Header
    
    private var greetingHeader: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xxxSmall) {
            Text(greeting)
                .font(.system(size: Theme.Typography.largeTitle, weight: Theme.Typography.bold))
                .foregroundColor(Theme.Colors.textPrimary)
            
            Text("Reflect in your daily journal")
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
    
    // MARK: - Month/Year Picker
    
    private var monthYearPickerView: some View {
        NavigationStack {
            VStack(spacing: Theme.Spacing.large) {
                DatePicker(
                    "Select Month & Year",
                    selection: $viewModel.currentMonth,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .tint(Theme.Colors.lavenderDark)
                .colorScheme(.light)
                .padding()
                .background(Color.white)
                .cornerRadius(Theme.CornerRadius.large)
                .padding(.horizontal)
                
                Button("Done") {
                    showMonthYearPicker = false
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
                .padding(.horizontal)
            }
            .padding(.vertical, Theme.Spacing.large)
            .background(Theme.Colors.softLavender)
            .navigationTitle("Select Month & Year")
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium])
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
            
            // Month and year - tappable to select
            Button(action: {
                showMonthYearPicker = true
            }) {
                VStack(spacing: Theme.Spacing.xxxSmall) {
                    Text(viewModel.monthYearString)
                        .font(.system(size: Theme.Typography.title3, weight: Theme.Typography.bold))
                        .foregroundColor(Theme.Colors.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    
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
            }
            .buttonStyle(PlainButtonStyle())
            
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
                .simultaneousGesture(
                    DragGesture(minimumDistance: 50)
                        .onEnded { value in
                            handleSwipe(value)
                        }
                )
        )
        .padding(.horizontal, Theme.Spacing.xSmall)
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
        print("🗓️ [CalendarView] Date tapped: \(date)")
        print("📝 [CalendarView] Entry exists: \(viewModel.entry(for: date) != nil)")
        
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        withAnimation(Theme.Animation.spring) {
            let entry = viewModel.selectDate(date)
            print("✅ [CalendarView] Calling onDateSelected with date: \(date), entry: \(entry != nil)")
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
    
    @State private var shadowOpacity: Double = 0.3
    
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
                    .font(.system(size: Theme.Typography.subheadline, weight: (isToday || isSelected) ? Theme.Typography.bold : Theme.Typography.medium))
                    .foregroundColor(isFuture ? Theme.Colors.textSecondary.opacity(0.5) : Theme.Colors.textPrimary)
                
                // Mood emoji or indicator
                if let entry = entry {
                    Text(entry.mood.emoji)
                        .font(.system(size: 24))
                } else {
                    Circle()
                        .fill(isFuture ? Color.clear : Theme.Colors.textSecondary.opacity(0.25))
                        .frame(width: 6, height: 6)
                }
            }
            .frame(maxWidth: .infinity)
            .aspectRatio(1, contentMode: .fit)
            .background(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.large)
                    .fill(backgroundColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.large)
                    .strokeBorder(borderColor, lineWidth: (isToday || isSelected) ? 2.5 : 0)
            )
            .shadow(
                color: (isToday || isSelected) ? Theme.Colors.cherryBlossomPink.opacity(shadowOpacity) : Color.clear,
                radius: (isToday || isSelected) ? 6 : 0,
                x: 0,
                y: 0
            )
            .onAppear {
                if isToday || isSelected {
                    print("✨ [DayCell] Starting shadow pulse for \(isToday ? "today" : "selected") date")
                    startShadowPulse()
                }
            }
            .onChange(of: isSelected) { _, newValue in
                if newValue {
                    print("✨ [DayCell] Date selected, starting pulse")
                    startShadowPulse()
                } else {
                    print("✨ [DayCell] Date deselected, stopping pulse")
                    stopShadowPulse()
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isFuture)
    }
    
    private func startShadowPulse() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(
                .easeInOut(duration: 1.8)
                .repeatForever(autoreverses: true)
            ) {
                shadowOpacity = 0.6
            }
        }
    }
    
    private func stopShadowPulse() {
        withAnimation(.easeOut(duration: 0.4)) {
            shadowOpacity = 0.3
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


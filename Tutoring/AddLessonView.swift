//
//  AddLessonView.swift
//  Tutoring
//
//  Created by Oleksandr Yasinskyi on 09/01/2025.
//

import SwiftUI
import SwiftData

struct AddLessonView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @Bindable var subject: Subject
    @State private var monthlySchedule: Bool = false
    @State private var defaultDayOfWeek: WeekDay
    @State private var selectedMonth: Date
    @State private var date = Date()
    @State private var price: Double
    @State private var duration: Double
    @State private var comment: String = ""
    @State private var status: LessonStatus = .new
    @Query private var settings: [AppSettings]
    var currencyCode: String {
        settings.first?.currencyCode ?? "USD"
    }
    
    init(subject: Subject, monthlySchedule: Bool, selectedMonth: Date) {
        self.subject = subject
        _defaultDayOfWeek = State(initialValue: subject.defaultDayOfWeek)
        _date = State(initialValue: subject.getClosestDate() ?? Date())
        _price = State(initialValue: subject.defaultPrice)
        _duration = State(initialValue: Double(subject.defaultDuration))
        _monthlySchedule = State(initialValue: monthlySchedule)
        _selectedMonth = State(initialValue: selectedMonth)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Lesson Details")) {
                    if monthlySchedule {
                        Picker("Day of week", selection: $defaultDayOfWeek) {
                            ForEach(WeekDay.allCases, id: \.self) { day in
                                Text(day.description).tag(day)
                            }
                        }
                        DatePicker("Start time", selection: $date, displayedComponents: .hourAndMinute)
                    } else {
                        DatePicker("Date and Time", selection: $date)
                    }
                    HStack {
                        Text("Price")
                        Spacer()
                        TextField("Price", value: $price, format: .currency(code: currencyCode))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Duration (minutes)")
                        Spacer()
                        TextField("Duration", value: $duration, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
                if !monthlySchedule {
                    Section(header: Text("Status")) {
                        Picker("Status", selection: $status) {
                            Text("🟦 New").tag(LessonStatus.new)
                            Text("🟥 Done").tag(LessonStatus.done)
                            Text("🟩 Paid").tag(LessonStatus.paid)
                        }.pickerStyle(.segmented)
                    }
                }
                Section(header: Text("Additional information")) {
                    TextEditor(text: $comment)
                        .frame(height: 100)
                }
            }
            .navigationTitle("Add lesson")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if monthlySchedule {
                            createMonthlySchedule()
                        } else {
                            addLesson()
                        }
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func addLesson() {
        let newLesson = Lesson(
            date: date,
            status: status,
            price: price,
            duration: Int(duration),
            comment: comment.isEmpty ? nil : comment,
            subject: subject
        )
        withAnimation {
            subject.lessons.append(newLesson)
            modelContext.insert(newLesson)
            try? modelContext.save()
        }
    }
    
    private func createMonthlySchedule() {
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: selectedMonth)
        let currentYear = calendar.component(.year, from: selectedMonth)
        let weekdaySymbol = defaultDayOfWeek
        // Extract the time from the `date` state
        let timeOfDay = calendar.component(.hour, from: date) * 3600 + calendar.component(.minute, from: date) * 60
        // Generate all dates for the selected weekday in the current month
        let datesForMonth = getDatesForWeekdayInMonth(weekday: weekdaySymbol, month: currentMonth, year: currentYear)
        for date in datesForMonth {
            var lessonDate = calendar.date(bySettingHour: calendar.component(.hour, from: date),
                                           minute: calendar.component(.minute, from: date),
                                           second: calendar.component(.second, from: date),
                                           of: date) ?? date
            lessonDate = calendar.date(byAdding: .second, value: timeOfDay, to: lessonDate) ?? lessonDate
            let newLesson = Lesson(
                date: lessonDate,
                status: .new,
                price: price,
                duration: Int(duration),
                comment: comment.isEmpty ? nil : comment,
                subject: subject
            )
            subject.lessons.append(newLesson)
            modelContext.insert(newLesson)
        }
        try? modelContext.save()
    }

    private func getDatesForWeekdayInMonth(weekday: WeekDay, month: Int, year: Int) -> [Date] {
        let calendar = Calendar.current
        var dates: [Date] = []
        // Get the first day of the current month
        let firstDayOfMonth = calendar.date(from: DateComponents(year: year, month: month, day: 1))!
        // Find the first weekday of the month
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        // Calculate the difference between the first day of the month and the desired weekday
        let weekdayDifference = (weekday.rawValue - firstWeekday + 7) % 7
        // Loop through the month and generate dates
        for week in 0..<5 { // Assuming at most 5 occurrences of the weekday in a month
            let dayOffset = (week * 7) + weekdayDifference
            if let date = calendar.date(byAdding: .day, value: dayOffset, to: firstDayOfMonth),
               calendar.component(.month, from: date) == month {
                dates.append(date)
            }
        }
        return dates
    }
    
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Subject.self, configurations: config)
    
    let subject = Subject(name: "Math")
    AddLessonView(subject: subject, monthlySchedule: false, selectedMonth: Date())
        .modelContainer(container)
}

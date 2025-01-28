//
//  LessonsView.swift
//  Tutoring
//
//  Created by Oleksandr Yasinskyi on 09/01/2025.
//

import SwiftUI
import SwiftData

struct LessonsView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Bindable var subject: Subject
    @State private var selectedMonth = Date()
    @State private var showAllLessons = false
    @State private var isAddingLesson = false
    @State private var showingDepositSheet = false
    @State private var showingSubjectDetails = false
    @State private var selectedLesson: Lesson?
    @Query private var settings: [AppSettings]
    private var isUserTutor: Bool {
        settings.first?.isUserTutor ?? false
    }
    var currencyCode: String {
        settings.first?.currencyCode ?? "USD"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            List {
                ForEach(filteredLessons) { lesson in
                    LessonRowView(lesson: lesson,
                                  currencyCode: currencyCode)
                        .onTapGesture {
                            selectedLesson = lesson
                        }
                }
                .onDelete(perform: deleteLessons)
            }
            Group {
                if showAllLessons {
                    let balance = isUserTutor ? subject.calculateTutorsBalance() : subject.calculateBalance()
                    Text("Total balance: ")
                    + Text("\(balance, format: .currency(code: currencyCode))")
                        .foregroundColor(balance > 0 ? .green : (balance < 0 ? .red : .black))
                } else {
                    let balance = isUserTutor ? tutorsMonthBalance : currentMonthBalance
                    Text("Monthly balance: ")
                    + Text("\(balance, format: .currency(code: currencyCode))")
                        .foregroundColor(balance > 0 ? .green : (balance < 0 ? .red : .black))
                }
            }
            .multilineTextAlignment(.center)
            .padding()
            // Month navigation
            HStack {
                if showAllLessons {
                    Text("All lessons")
                        .font(.headline)
                } else {
                    Button(action: previousMonth) {
                        Image(systemName: "chevron.left")
                    }
                    Text(selectedMonth, format: .dateTime.month(.wide).year())
                        .font(.headline)
                    Button(action: nextMonth) {
                        Image(systemName: "chevron.right")
                    }
//                    .disabled(isNextMonthDisabled)
                }
            }
            .padding()
        }
        .navigationTitle(subject.name)
        .toolbar {
            ToolbarItem {
                Button(action: showAddLessonSheet) {
                    Label("Add lesson", systemImage: "plus")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: { showingSubjectDetails = true }) {
                        Label("Subject details", systemImage: "info.circle")
                    }
                    if !isUserTutor {
                        Button(action: { showingDepositSheet = true }) {
                            Label("Add deposit", systemImage: "banknote")
                        }
                    }
                    Toggle(isOn: $showAllLessons) {
                        Label("Show all lessons", systemImage: "list.bullet")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(item: $selectedLesson) { lesson in
            LessonDetailsView(lesson: lesson)
        }
        .sheet(isPresented: $isAddingLesson) {
            AddLessonView(subject: subject)
        }
        .sheet(isPresented: $showingSubjectDetails) {
            SubjectDetailsView(subject: subject)
        }
        .sheet(isPresented: $showingDepositSheet) {
            AddDepositView(subject: subject)
        }
    }
    
    // MARK: Lesson displaying
    private var filteredLessons: [Lesson] {
        if showAllLessons {
            return subject.lessons.sorted(by: { $0.date > $1.date })
        }
        return subject.lessons.filter {
            Calendar.current.isDate($0.date, equalTo: selectedMonth, toGranularity: .month)
        }.sorted(by: { $0.date > $1.date })
    }
    
    struct LessonRowView: View {
        let lesson: Lesson
        let currencyCode: String
        
        var statusIcon: some View {
            Image(systemName: iconName)
                .foregroundColor(iconColor)
        }
        private var iconName: String {
            switch lesson.status {
            case .paid: return "checkmark.circle.fill"
            case .done: return "exclamationmark.circle.fill"
            case .new: return "circle.fill"
            }
        }
        private var iconColor: Color {
            switch lesson.status {
            case .paid: return .green
            case .done: return .red
            case .new: return .blue
            }
        }
        
        var body: some View {
            HStack {
                statusIcon
                VStack(alignment: .leading) {
                    Text(lesson.date.formatted(date: .long, time: .shortened))
                        .font(.headline)
                    Text("\(lesson.duration) min • \(lesson.price, format: .currency(code: currencyCode))")
                        .font(.caption)
                    if let comment = lesson.comment {
                        Text(comment)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        
    }
    
    // MARK: Lesson management
    private func deleteLessons(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let lesson = filteredLessons[index]
                modelContext.delete(lesson)
            }
            try? modelContext.save()
        }
    }
    
    private func showAddLessonSheet() {
        isAddingLesson = true
    }
    
    // MARK: Navigation helpers
//    private var isNextMonthDisabled: Bool {
//        !showAllLessons && Calendar.current.isDate(selectedMonth, equalTo: Date(), toGranularity: .month)
//    }
    
    private func previousMonth() {
        withAnimation {
            selectedMonth = Calendar.current.date(byAdding: .month, value: -1, to: selectedMonth)!
        }
    }
    
    private func nextMonth() {
        withAnimation {
            selectedMonth = Calendar.current.date(byAdding: .month, value: 1, to: selectedMonth)!
        }
    }
    
    // MARK: Balance
    private var carryOverBalance: Double {
        let previousMonthEnd = Calendar.current.date(byAdding: .month, value: -1, to: selectedMonth)!
        return subject.lessons
            .filter { $0.date <= previousMonthEnd }
            .reduce(0) { total, lesson in
                if lesson.status == .paid {
                    return total - lesson.price
                }
                return total
            } + subject.deposits
            .filter { $0.date <= previousMonthEnd }
            .reduce(0) { $0 + $1.amount }
    }
    
    private var currentMonthBalance: Double {
        let monthLessons = subject.lessons.filter {
            Calendar.current.isDate($0.date, equalTo: selectedMonth, toGranularity: .month)
        }
        let monthDeposits = subject.deposits.filter {
            Calendar.current.isDate($0.date, equalTo: selectedMonth, toGranularity: .month)
        }
        let lessonsCost = monthLessons
            .filter { $0.status == .paid }
            .reduce(0) { $0 + $1.price }
        let depositsSum = monthDeposits.reduce(0) { $0 + $1.amount }
        return carryOverBalance + depositsSum - lessonsCost
    }
    
    private var tutorsMonthBalance: Double {
        let monthLessons = subject.lessons.filter {
            Calendar.current.isDate($0.date, equalTo: selectedMonth, toGranularity: .month)
        }
        let paidCost = monthLessons
            .filter { $0.status == .paid }
            .reduce(0) { $0 + $1.price }
        let uppaidCost = monthLessons
            .filter { $0.status == .done }
            .reduce(0) { $0 + $1.price }
        return paidCost - uppaidCost
    }

}

//#Preview {
//    let config = ModelConfiguration(isStoredInMemoryOnly: true)
//    let container = try! ModelContainer(for: Subject.self, configurations: config)
//    
//    let subject = Subject(name: "Math")
//    LessonsView(subject: subject)
//        .modelContainer(container)
//}

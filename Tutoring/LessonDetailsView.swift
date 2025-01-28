//
//  LessonDetailsView.swift
//  Tutoring
//
//  Created by Oleksandr Yasinskyi on 27/01/2025.
//

import SwiftUI
import SwiftData

struct LessonDetailsView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    @Bindable var lesson: Lesson
    
    @State private var date: Date
    @State private var price: Double
    @State private var duration: Double
    @State private var comment: String
    @State private var status: LessonStatus
    @Query private var settings: [AppSettings]
    var currencyCode: String {
        settings.first?.currencyCode ?? "USD"
    }
    
    init(lesson: Lesson) {
        self.lesson = lesson
        _date = State(initialValue: lesson.date)
        _price = State(initialValue: lesson.price)
        _duration = State(initialValue: Double(lesson.duration))
        _comment = State(initialValue: lesson.comment ?? "")
        _status = State(initialValue: lesson.status)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section() {
                    DatePicker("Date and time", selection: $date)
                    
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
                
                Section(header: Text("Status")) {
                    Picker("Status", selection: $status) {
                        Text("🟦 New").tag(LessonStatus.new)
                        Text("🟥 Done").tag(LessonStatus.done)
                        Text("🟩 Paid").tag(LessonStatus.paid)
                    }.pickerStyle(.segmented)
                }
                
                Section(header: Text("Additional information")) {
                    TextEditor(text: $comment)
                        .frame(height: 100)
                }
            }
            .navigationTitle("Lesson details")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveChanges()
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func saveChanges() {
        lesson.date = date
        lesson.price = price
        lesson.duration = Int(duration)
        lesson.comment = comment.isEmpty ? nil : comment
        lesson.status = status
        
        try? modelContext.save()
    }
    
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Subject.self, configurations: config)
    
    let subject = Subject(name: "Math")
    let lesson = Lesson(
        date: Date(),
        status: .new,
        price: 50.0,
        duration: 45,
        comment: "Test lesson",
        subject: subject
    )
    
    LessonDetailsView(lesson: lesson)
        .modelContainer(container)
}

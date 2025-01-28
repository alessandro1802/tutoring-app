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
    @State private var date = Date()
    @State private var price: Double
    @State private var duration: Double
    @State private var comment: String = ""
    @State private var status: LessonStatus = .new
    @Query private var settings: [AppSettings]
    var currencyCode: String {
        settings.first?.currencyCode ?? "USD"
    }
    
    init(subject: Subject) {
        self.subject = subject
        _date = State(initialValue: subject.getClosestDate() ?? Date())
        _price = State(initialValue: subject.defaultPrice)
        _duration = State(initialValue: Double(subject.defaultDuration))
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Lesson Details")) {
                    DatePicker("Date and Time", selection: $date)
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
            .navigationTitle("Add lesson")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        addLesson()
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
    
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Subject.self, configurations: config)
    
    let subject = Subject(name: "Math")
    AddLessonView(subject: subject)
        .modelContainer(container)
}

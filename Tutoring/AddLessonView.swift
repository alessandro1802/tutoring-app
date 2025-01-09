//
//  AddLessonView.swift
//  Tutoring
//
//  Created by Oleksandr Yasinskyi on 09/01/2025.
//

import SwiftUI

struct AddLessonView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @Bindable var subject: Subject
    @State private var title = ""
    @State private var date = Date()

    var body: some View {
        NavigationView {
            Form {
                TextField("Lesson Title", text: $title)
                DatePicker("Date", selection: $date, displayedComponents: .date)
            }
            .navigationTitle("Add Lesson")
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
        let newLesson = Lesson(title: title, date: date, subject: subject)
        withAnimation {
            subject.lessons.append(newLesson)
            modelContext.insert(newLesson)
            try? modelContext.save()
        }
    }

}

//
//  LessonsView.swift
//  Tutoring
//
//  Created by Oleksandr Yasinskyi on 09/01/2025.
//

import SwiftUI
import SwiftData

struct LessonsView: View {
    @Bindable var subject: Subject
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        List {
            ForEach(subject.lessons, id: \.id) { lesson in
                VStack(alignment: .leading) {
                    Text(lesson.title)
                        .font(.headline)
                    Text(lesson.date, style: .date)
                        .font(.caption)
                }
            }
            .onDelete { offsets in
                deleteLessons(offsets: offsets)
            }
        }
        .navigationTitle(subject.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: showAddLessonSheet) {
                    Label("Add Lesson", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $isAddingLesson) {
            AddLessonView(subject: subject)
        }
    }

    // MARK: - Lesson Management
    @State private var isAddingLesson = false

    private func deleteLessons(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let lesson = subject.lessons[index]
                modelContext.delete(lesson)
            }
            try? modelContext.save()
        }
    }

    private func showAddLessonSheet() {
        isAddingLesson = true
    }
}


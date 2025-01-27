//
//  ContentView.swift
//  Tutoring
//
//  Created by Oleksandr Yasinskyi on 07/01/2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Subject.timestamp, order: .reverse) private var subjects: [Subject]

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(subjects) { subject in
                    NavigationLink {
                        LessonsView(subject: subject)
                    } label: {
                        SubjectRowView(subject: subject)
                    }
                }
                .onDelete(perform: deleteSubjects)
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Tutoring").font(.title)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addSubject) {
                        Label("Add subject", systemImage: "plus")
                    }
                }
            }
        } detail: {
            Text("Select a subject")
        }
    }
    
    // MARK: - Subject Row View
    struct SubjectRowView: View {
        let subject: Subject
        @Environment(\.modelContext) private var modelContext
        
        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text(subject.name)
                    .font(.headline)
                
                if let comment = subject.comment, !comment.isEmpty {
                    Text(comment)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Balance: ")
                    Text(String(format: "%.2f", subject.balance))
                        .foregroundColor(subject.balance >= 0 ? .green : .red)
                }
                .font(.caption)
            }
        }
    }

    // MARK: - Subject management
    private func addSubject() {
        let alert = UIAlertController(title: "Add Subject", message: "Enter a name for the new subject", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Subject name"
        }
        alert.addTextField { textField in
            textField.placeholder = "Comment (optional)"
        }
        let addAction = UIAlertAction(title: "Add", style: .default) { _ in
            // Add the new Subject if the name is valid
            if let nameField = alert.textFields?[0], let name = nameField.text, !name.isEmpty {
                let commentField = alert.textFields?[1]
                let comment = commentField?.text ?? ""
                let newSubject = Subject(
                    name: name,
                    comment: comment.isEmpty ? nil : comment
                )
                withAnimation {
                    modelContext.insert(newSubject)
                    // Save changes to the persistent store
                    try? modelContext.save()
                }
            } else {
                if let nameField = alert.textFields?[0] {
                    let animation = CABasicAnimation(keyPath: "position")
                    animation.duration = 0.05
                    animation.repeatCount = 3
                    animation.autoreverses = true
                    animation.fromValue = NSValue(cgPoint: CGPoint(x: alert.view.center.x - 10, y: alert.view.center.y))
                    animation.toValue = NSValue(cgPoint: CGPoint(x: alert.view.center.x + 10, y: alert.view.center.y))
                    alert.view.layer.add(animation, forKey: "position")
                    
                    nameField.attributedPlaceholder = NSAttributedString(
                        string: "Name is required",
                        attributes: [NSAttributedString.Key.foregroundColor: UIColor.red]
                    )
                }
                // Re-present the alert to keep it open
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootViewController = windowScene.windows.first?.rootViewController {
                    rootViewController.present(alert, animated: true, completion: nil)
                }
            }
        }
        alert.addAction(addAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        // Present the alert
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(alert, animated: true, completion: nil)
        }
    }

    private func deleteSubjects(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let subject = subjects[index]
                modelContext.delete(subject)
            }
            // Save changes to the persistent store
            try? modelContext.save()
        }
    }

}

#Preview {
    ContentView()
        .modelContainer(for: Subject.self, inMemory: true)
}

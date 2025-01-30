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
    @State private var showArchived: Bool = false
    @Query private var subjects: [Subject]
    @Query private var settings: [AppSettings]
    
    var isUserTutor: Bool {
        settings.first?.isUserTutor ?? false
    }
    var currencyCode: String {
        settings.first?.currencyCode ?? "USD"
    }

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(filteredSubjects) { subject in
                    NavigationLink {
                        LessonsView(subject: subject)
                    } label: {
                        SubjectRowView(subject: subject,
                                       isUserTutor: isUserTutor,
                                       currencyCode: currencyCode)
                    }
                }
                .onDelete(perform: deleteSubjects)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: toggleArchiveView) {
                        if showArchived{
                            Label("Back", systemImage: "rectangle.lefthalf.inset.filled.arrow.left")
                        } else {
                            Label("Archive", systemImage: "archivebox.fill")
                        }
                    }
                }
                ToolbarItem(placement: .principal) {
                    if showArchived {
                        Text("Arhived subjects").font(.headline)
                    } else {
                        Text("Tutoring").font(.title).bold()
                    }
                }
                ToolbarItem {
                    HStack(spacing: 3) {
                        if !showArchived {
                            Button(action: addSubject) {
                                Label("Add", systemImage: "plus")
                            }
                        }
                        EditButton()
                        NavigationLink(destination: SettingsView()) {
                            Label("Settings", systemImage: "gear")
                        }
                    }
                }
            }
        } detail: {
            Text("Select a subject")
        }
    }
    
    // MARK: Subject displaying
    private var filteredSubjects: [Subject] {
        subjects
            .filter { $0.isArchived == showArchived }
            .sorted { $0.name < $1.name }
    }
    
    struct SubjectRowView: View {
        let subject: Subject
        let isUserTutor: Bool
        let currencyCode: String
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
                    let balance = isUserTutor ? subject.calculateTutorsBalance() : subject.calculateBalance()
                    Text("Balance:")
                    Text("\(balance, format: .currency(code: currencyCode))")
                        .foregroundColor(balance > 0 ? .green : (balance < 0 ? .red : .black))
                }
                .font(.caption)
            }
        }
        
    }
    
    private func toggleArchiveView() {
        showArchived.toggle()
    }

    // MARK: Subject management
    private func addSubject() {
        let alert: UIAlertController
        if isUserTutor {
            alert = UIAlertController(title: "Add student", message: "Enter the name of the student", preferredStyle: .alert)
            alert.addTextField { textField in
                textField.placeholder = "Student name"
            }
        } else {
            alert = UIAlertController(title: "Add subject", message: "Enter the name of the subject", preferredStyle: .alert)
            alert.addTextField { textField in
                textField.placeholder = "Subject name"
            }
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
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootViewController = windowScene.windows.first?.rootViewController {
                    rootViewController.present(alert, animated: true, completion: nil)
                }
            }
        }
        alert.addAction(addAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(alert, animated: true, completion: nil)
        }
    }

    private func deleteSubjects(offsets: IndexSet) {
        for index in offsets {
            let subject = filteredSubjects[index]
            modelContext.delete(subject)
        }
        try? modelContext.save()
    }
    
}

//#Preview {
//    ContentView()
//        .modelContainer(for: Subject.self, inMemory: true)
//}

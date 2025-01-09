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
    @Query(sort: \Subject.timestamp, order: .reverse) private var items: [Subject]

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(items) { item in
                    NavigationLink {
                        LessonsView(subject: item)
                    } label: {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(item.name).font(.headline)
                            Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard)).font(.caption)
                        }
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Tutoring").font(.title)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add subject", systemImage: "plus")
                    }
                }
            }
        } detail: {
            Text("Select a subject")
        }
    }

    // MARK: - Subject management
    private func addItem() {
        withAnimation {
            let alert = UIAlertController(title: "Add Subject", message: "Enter a name for the new subject", preferredStyle: .alert)
            alert.addTextField { textField in
                textField.placeholder = "Subject Name"
            }
            alert.addTextField { textField in
                textField.placeholder = "Coment (optional)"
            }
            // Action without automatic dismissal
            let addAction = UIAlertAction(title: "Add", style: .default) { _ in
                if let nameField = alert.textFields?[0], let name = nameField.text, !name.isEmpty {
                    // Add the new item if the name is valid
                    let comentField = alert.textFields?[1]
                    let coment = comentField?.text ?? ""
                    
                    let newItem = Subject(name: name, timestamp: Date(), comment: coment)
                    modelContext.insert(newItem)
                    // Save changes to the persistent store
                    try? modelContext.save()
                    
                } else {
                    // Keep the alert open and show error indicators
                    if let nameField = alert.textFields?[0] {
                        // Shake animation for the alert
                        let animation = CABasicAnimation(keyPath: "position")
                        animation.duration = 0.05
                        animation.repeatCount = 3
                        animation.autoreverses = true
                        animation.fromValue = NSValue(cgPoint: CGPoint(x: alert.view.center.x - 10, y: alert.view.center.y))
                        animation.toValue = NSValue(cgPoint: CGPoint(x: alert.view.center.x + 10, y: alert.view.center.y))
                        alert.view.layer.add(animation, forKey: "position")
                        // Change the text field placeholder to red
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
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let subject = items[index]
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

//
//  SettingsView.swift
//  Tutoring
//
//  Created by Oleksandr Yasinskyi on 28/01/2025.
//


import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var settings: [AppSettings]
    @State private var isUserTutor: Bool = false
    @State private var currencyCode: String = "USD"
    
    let currencyOptions = ["PLN", "UAH", "USD", "EUR", "GBP", "JPY"]
    let defaultCurrencyCode: String = "USD"
    
    var body: some View {
        VStack(spacing: 0) {
            Form {
                Section("User Type") {
                    Toggle("I am a tutor", isOn: $isUserTutor)
                        .onChange(of: isUserTutor) { _, newValue in
                            saveSettings(isTutor: newValue)
                        }
                }
                Section("Currency") {
                    Picker("Currency", selection: $currencyCode) {
                        ForEach(currencyOptions, id: \.self) { currency in
                            Text(currency).tag(currency)
                        }
                    }
                    .pickerStyle(.menu)
                    .onChange(of: currencyCode) { _, newValue in
                        saveCurrency(newValue)
                    }
                }
                Section("About") {
                    LabeledContent("Version", value: "1.0")
                    Text("This application helps managing tutoring lessons, schedules, and payments for both tutors and students. Both types of users can track which lessons are paid. Students are able to add funds per subject and see how much they spend on learning, while teachers can fascilitate their earnings.")
                        .foregroundColor(.secondary)
                    Text("© \(Calendar.current.component(.year, from: Date())) Oleksandr Yasinskyi")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            // Update the state from the current settings when the view appears
            isUserTutor = settings.first?.isUserTutor ?? false
            currencyCode = settings.first?.currencyCode ?? defaultCurrencyCode
            // Create initial settings if none exist
            if settings.isEmpty {
                let initialSettings = AppSettings(isUserTutor: false)
                modelContext.insert(initialSettings)
                try? modelContext.save()
            }
        }
    }
    
    // MARK: Saving
    private func saveSettings(isTutor: Bool) {
        if let existingSettings = settings.first {
            existingSettings.isUserTutor = isTutor
        } else {
            let newSettings = AppSettings(isUserTutor: isTutor)
            modelContext.insert(newSettings)
        }
        try? modelContext.save()
    }
    
    private func saveCurrency(_ currencyCode: String) {
        if let existingSettings = settings.first {
            existingSettings.currencyCode = currencyCode
        } else {
            let newSettings = AppSettings()
            newSettings.currencyCode = currencyCode
            modelContext.insert(newSettings)
        }
        try? modelContext.save()
    }
    
}

#Preview {
    SettingsView()
}

//
//  SubjectDetailsView.swift
//  Tutoring
//
//  Created by Oleksandr Yasinskyi on 27/01/2025.
//

import SwiftUI

import SwiftUI
import SwiftData

struct SubjectDetailsView: View {
    @Environment(\.dismiss) var dismiss
    @Bindable var subject: Subject
    @State private var name: String
    @State private var comment: String
    @State private var defaultPrice: Double
    @State private var defaultDuration: Double
    @State private var defaultDayOfWeek: WeekDay
    @State private var defaultStartTime: Date
    @State private var isArchived: Bool
    @Query private var settings: [AppSettings]
    private var isUserTutor: Bool {
        settings.first?.isUserTutor ?? false
    }
    
    init(subject: Subject) {
        self.subject = subject
        _name = State(initialValue: subject.name)
        _comment = State(initialValue: subject.comment ?? "")
        _defaultPrice = State(initialValue: subject.defaultPrice)
        _defaultDuration = State(initialValue: Double(subject.defaultDuration))
        _defaultDayOfWeek = State(initialValue: subject.defaultDayOfWeek)
        _defaultStartTime = State(initialValue: Calendar.current.date(bySettingHour: subject.defaultHour,
                                                                      minute: subject.defaultMinute, second: 0,
                                                                      of: Date()) ?? Date())
        _isArchived = State(initialValue: subject.isArchived)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Basic information") {
                    TextField("Name", text: $name)
                    TextField("Comment", text: $comment)
                }
                Section("Default lesson settings") {
                    HStack {
                        Text("Price")
                        Spacer()
                        TextField("Price", value: $defaultPrice, format: .currency(code: "PLN"))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Duration (minutes)")
                        Spacer()
                        TextField("Duration", value: $defaultDuration, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
                Section("Default schedule") {
                    Picker("Day of week", selection: $defaultDayOfWeek) {
                        ForEach(WeekDay.allCases, id: \.self) { day in
                            Text(day.description).tag(day)
                        }
                    }
                    
                    DatePicker("Start time", selection: $defaultStartTime, displayedComponents: .hourAndMinute)
                }
                
                Section {
                    Toggle("Archive subject", isOn: $isArchived)
                }
                
                Section("Financial summary") {
                    let balance = isUserTutor ? subject.calculateTutorsBalance() : subject.calculateBalance()
                    HStack {
                        Text("Total balance:")
                        Text("\(balance, format: .currency(code: "PLN"))")
                            .foregroundColor(balance > 0 ? .green : (balance < 0 ? .red : .black))
                    }
                }
            }
            .navigationTitle("Subject details")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
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
        subject.name = name
        subject.comment = comment.isEmpty ? nil : comment
        subject.defaultPrice = defaultPrice
        subject.defaultDuration = Int(defaultDuration)
        subject.defaultDayOfWeek = defaultDayOfWeek
        let components = Calendar.current.dateComponents([.hour, .minute], from: defaultStartTime)
        subject.defaultHour = components.hour ?? 0
        subject.defaultMinute = components.minute ?? 0
        subject.isArchived = isArchived
    }
    
}

extension WeekDay: CaseIterable, CustomStringConvertible {
    static var allCases: [WeekDay] = [.sunday, .monday, .tuesday, .wednesday, .thursday, .friday, .saturday]
    
    var description: String {
        switch self {
        case .sunday: return "Sunday"
        case .monday: return "Monday"
        case .tuesday: return "Tuesday"
        case .wednesday: return "Wednesday"
        case .thursday: return "Thursday"
        case .friday: return "Friday"
        case .saturday: return "Saturday"
        }
    }
    
}

#Preview {  
    let subject = Subject(name: "Math")
    SubjectDetailsView(subject: subject)
}

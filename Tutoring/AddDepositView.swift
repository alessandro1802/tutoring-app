//
//  AddDepositView.swift
//  Tutoring
//
//  Created by Oleksandr Yasinskyi on 28/01/2025.
//


import SwiftUI

struct AddDepositView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @Bindable var subject: Subject
    @State private var amount: Double = 0.0
    @State private var date = Date()
    
    var body: some View {
        NavigationView {
            Form {
                Section("Details") {
                    HStack {
                        Text("Amount")
                        Spacer()
                        TextField("Amount", value: $amount, format: .currency(code: "PLN"))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    DatePicker("Date", selection: $date)
                }
                Section("Current balance") {
                    let balance = subject.calculateBalance()
                    Text("\(balance, format: .currency(code: "PLN"))")
                        .foregroundColor(balance > 0 ? .green : (balance < 0 ? .red : .black))
                }
            }
            .navigationTitle("Add deposit")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        withAnimation {
                            addDeposit()
                            dismiss()
                        }
                    }
                    .disabled(amount <= 0)
                }
            }
        }
    }
    
    private func addDeposit() {
        let newDeposit = Deposit(amount: amount, date: date, subject: subject)
        subject.deposits.append(newDeposit)
        modelContext.insert(newDeposit)
        try? modelContext.save()
    }
    
    
}

#Preview {
    let subject = Subject(name: "Math")
    AddDepositView(subject: subject)
}

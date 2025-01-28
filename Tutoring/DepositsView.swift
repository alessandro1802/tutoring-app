//
//  DepositsView.swift
//  Tutoring
//
//  Created by Oleksandr Yasinskyi on 28/01/2025.
//


import SwiftUI
import SwiftData

struct DepositsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    
    @Bindable var subject: Subject
    @Query private var settings: [AppSettings]
    var currencyCode: String {
        settings.first?.currencyCode ?? "USD"
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(subject.deposits.sorted(by: { $0.date < $1.date })) { deposit in
                    HStack {
                        Text(deposit.amount, format: .currency(code: currencyCode))
                        Spacer()
                        Text(deposit.date, style: .date)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 5)
                }
            }
            .navigationTitle("Deposits")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        dismiss()
                    }
                }
            }
        }
    }
    
}

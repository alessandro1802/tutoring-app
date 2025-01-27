//
//  Deposit.swift
//  Tutoring
//
//  Created by Oleksandr Yasinskyi on 27/01/2025.
//

import Foundation
import SwiftData

@Model
class Deposit {
    var id: UUID
    var amount: Double
    var date: Date
    @Relationship(deleteRule: .cascade) var subject: Subject
    
    init(
        id: UUID = UUID(),
        amount: Double,
        date: Date = Date(),
        subject: Subject
    ) {
        self.id = id
        self.amount = amount
        self.date = date
        self.subject = subject
    }
    
}

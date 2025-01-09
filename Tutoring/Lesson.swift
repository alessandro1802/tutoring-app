//
//  Lesson.swift
//  Tutoring
//
//  Created by Oleksandr Yasinskyi on 09/01/2025.
//

import Foundation
import SwiftData

@Model
class Lesson {
    var id: UUID
    var title: String
    var date: Date
    @Relationship(deleteRule: .cascade) var subject: Subject

    init(id: UUID = UUID(), title: String, date: Date, subject: Subject) {
        self.id = id
        self.title = title
        self.date = date
        self.subject = subject
    }
}

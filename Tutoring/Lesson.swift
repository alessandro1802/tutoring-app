//
//  Lesson.swift
//  Tutoring
//
//  Created by Oleksandr Yasinskyi on 09/01/2025.
//

import Foundation
import SwiftData

enum LessonStatus: String, Codable {
    case new     // scheduled but not done
    case done    // finished but not paid
    case paid    // finished and paid
}

@Model
class Lesson {
    var id: UUID
    var date: Date
    var status: LessonStatus
    var price: Double
    var duration: Int  // in minutes
    var comment: String?
    
    @Relationship(inverse: \Subject.lessons) var subject: Subject?
    
    init(
        id: UUID = UUID(),
        date: Date,
        status: LessonStatus = .new,
        price: Double,
        duration: Int = 45,
        comment: String? = nil,
        subject: Subject
    ) {
        self.id = id
        self.date = date
        self.status = status
        self.price = price
        self.duration = duration
        self.comment = comment
        self.subject = subject
    }
    
}

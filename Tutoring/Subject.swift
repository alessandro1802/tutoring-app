//
//  Item.swift
//  Tutoring
//
//  Created by Oleksandr Yasinskyi on 07/01/2025.
//

import Foundation
import SwiftData

@Model
final class Subject {
    var id: UUID
    var name: String
    var timestamp: Date
    var comment: String?
    @Relationship(deleteRule: .cascade) var lessons: [Lesson] = []
    
    init(id: UUID = UUID(), name: String, timestamp: Date = Date(), comment: String? = nil) {
        self.id = id
        self.name = name
        self.timestamp = timestamp
        self.comment = comment
    }
}

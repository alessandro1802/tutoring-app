//
//  Item.swift
//  Tutoring
//
//  Created by Oleksandr Yasinskyi on 07/01/2025.
//

import Foundation
import SwiftData

enum WeekDay: Int, Codable {
    case sunday = 1
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7
}

@Model
final class Subject {
    var id: UUID
    var name: String
    var timestamp: Date
    var comment: String?
    var isArchived: Bool
    
    // Default lesson settings
    var defaultPrice: Double
    var defaultDuration: Int
    var defaultDayOfWeek: WeekDay
//    var defaultStartTime: Date?
    var defaultHour: Int
    var defaultMinute: Int
    
    // Relationships
    @Relationship(deleteRule: .cascade) var lessons: [Lesson] = []
    @Relationship(deleteRule: .cascade) var deposits: [Deposit] = []
    
    init(
        id: UUID = UUID(),
        name: String,
        timestamp: Date = Date(),
        comment: String? = nil,
        isArchived: Bool = false,
        defaultPrice: Double = 50.0,
        defaultDuration: Int = 60,
        defaultDayOfWeek: WeekDay = .monday,
        defaultHour: Int = 11,
        defaultMinute: Int = 0
    ) {
        self.id = id
        self.name = name
        self.timestamp = timestamp
        self.comment = comment
        self.isArchived = isArchived
        self.defaultPrice = defaultPrice
        self.defaultDuration = defaultDuration
        self.defaultDayOfWeek = defaultDayOfWeek
        self.defaultHour = defaultHour
        self.defaultMinute = defaultMinute
    }
  
    func getClosestDate() -> Date? {
        let calendar = Calendar.current
        let now = Date()
        // Get the current weekday
        let currentWeekday = calendar.component(.weekday, from: now)
        // Calculate the difference in days to the target weekday
        var dayDifference = defaultDayOfWeek.rawValue - currentWeekday
        if dayDifference < 0 {
            dayDifference += 7
        }
        // Add the day difference to the current date
        if let targetDate = calendar.date(byAdding: .day, value: dayDifference, to: now) {
            // Set the target time
            var components = calendar.dateComponents([.year, .month, .day], from: targetDate)
            components.hour = defaultHour
            components.minute = defaultMinute
            return calendar.date(from: components)
        }
        return nil
    }

    
    // Computed property to calculate total balance
    var balance: Double {
        let totalDeposits = deposits.reduce(0) { $0 + $1.amount }
        let totalLessonsCost = lessons.filter { $0.status != .new }.reduce(0) { $0 + $1.price }
        return totalDeposits - totalLessonsCost
    }
    
}

//
//  Item.swift
//  Tutoring
//
//  Created by Oleksandr Yasinskyi on 07/01/2025.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}

//
//  AppSettings.swift
//  Tutoring
//
//  Created by Oleksandr Yasinskyi on 28/01/2025.
//


import SwiftUI
import SwiftData

@Model
class AppSettings {
    var isUserTutor: Bool
    
    init(isUserTutor: Bool = false) {
        self.isUserTutor = isUserTutor
    }
}

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
    var currencyCode: String
    
    init(isUserTutor: Bool = false, currencyCode: String = "USD") {
        self.isUserTutor = isUserTutor
        self.currencyCode = currencyCode
    }
    
}

//
//  Weekday.swift
//  Tracker
//
//  Created by Simon Butenko on 04.09.2024.
//

import Foundation

enum Weekday: Int, CaseIterable {
    case monday = 1, tuesday, wednesday, thursday, friday, saturday, sunday

    var shortTitle: String {
        NSLocalizedString(String(describing: self).prefix(3).capitalized, comment: "Short name for \(self)")
    }

    var fullTitle: String {
        NSLocalizedString(String(describing: self).capitalized, comment: "Full name for \(self)")
    }
}

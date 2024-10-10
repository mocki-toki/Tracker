//
//  Weekday.swift
//  Tracker
//
//  Created by Simon Butenko on 04.09.2024.
//

import Foundation

enum Weekday: Int, CaseIterable {
    case monday = 1
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday

    var shortTitle: String {
        switch self {
        case .monday: return NSLocalizedString("Mon", comment: "Short name for Monday")
        case .tuesday: return NSLocalizedString("Tue", comment: "Short name for Tuesday")
        case .wednesday: return NSLocalizedString("Wed", comment: "Short name for Wednesday")
        case .thursday: return NSLocalizedString("Thu", comment: "Short name for Thursday")
        case .friday: return NSLocalizedString("Fri", comment: "Short name for Friday")
        case .saturday: return NSLocalizedString("Sat", comment: "Short name for Saturday")
        case .sunday: return NSLocalizedString("Sun", comment: "Short name for Sunday")
        }
    }

    var fullTitle: String {
        switch self {
        case .monday: return NSLocalizedString("Monday", comment: "Full name for Monday")
        case .tuesday: return NSLocalizedString("Tuesday", comment: "Full name for Tuesday")
        case .wednesday: return NSLocalizedString("Wednesday", comment: "Full name for Wednesday")
        case .thursday: return NSLocalizedString("Thursday", comment: "Full name for Thursday")
        case .friday: return NSLocalizedString("Friday", comment: "Full name for Friday")
        case .saturday: return NSLocalizedString("Saturday", comment: "Full name for Saturday")
        case .sunday: return NSLocalizedString("Sunday", comment: "Full name for Sunday")
        }
    }

}

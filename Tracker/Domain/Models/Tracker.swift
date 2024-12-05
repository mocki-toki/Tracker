//
//  Tracker.swift
//  Tracker
//
//  Created by Simon Butenko on 03.09.2024.
//

import UIKit

struct Tracker: Hashable {
    let id: UUID
    let name: String
    let emoji: String
    let colorName: String
    let schedule: Set<Weekday>?
    let isPinned: Bool
}

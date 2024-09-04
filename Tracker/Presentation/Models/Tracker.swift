//
//  Tracker.swift
//  Tracker
//
//  Created by Simon Butenko on 03.09.2024.
//

import UIKit

struct Tracker {
    let id: UUID
    let name: String
    let emoji: String
    let color: UIColor
    let schedule: Set<Weekday>? 
}

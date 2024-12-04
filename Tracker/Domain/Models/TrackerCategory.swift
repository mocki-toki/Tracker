//
//  TrackerCategory.swift
//  Tracker
//
//  Created by Simon Butenko on 03.09.2024.
//

import Foundation

struct TrackerCategory: Equatable {
    let id: UUID
    let name: String
    let trackers: [Tracker]
}

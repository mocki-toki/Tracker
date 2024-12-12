//
//  Tracker+Extension.swift
//  Tracker
//
//  Created by Simon Butenko on 25.11.2024.
//

import CoreData

extension Tracker {
    init(coreData: TrackerCoreData) {
        self.id = coreData.id!
        self.name = coreData.name!
        self.emoji = coreData.emoji!
        self.colorName = coreData.colorName!
        self.isPinned = coreData.isPinned
        self.schedule = Set(
            coreData.schedule?
                .split(separator: ",")
                .compactMap { Weekday(rawValue: Int($0)!) } ?? [])
    }
}

extension TrackerCoreData {
    convenience init(data: Tracker, context: NSManagedObjectContext) {
        self.init(context: context)
        self.id = data.id
        self.name = data.name
        self.isPinned = data.isPinned
    }
}

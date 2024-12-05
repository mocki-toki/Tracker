//
//  TrackerCategory+Extension.swift
//  Tracker
//
//  Created by Simon Butenko on 25.11.2024.
//

import CoreData

extension TrackerCategory {
    init(coreData: TrackerCategoryCoreData) {
        self.id = coreData.id!
        self.name = coreData.name!
        self.trackers =
            (coreData.trackers as? Set<TrackerCoreData>)?.map { Tracker(coreData: $0) }.sorted(by: {
                $0.id.uuidString < $1.id.uuidString
            }) ?? []
    }
}

extension TrackerCategoryCoreData {
    convenience init(data: TrackerCategory, context: NSManagedObjectContext) {
        self.init(context: context)
        self.id = data.id
        self.name = data.name
    }
}

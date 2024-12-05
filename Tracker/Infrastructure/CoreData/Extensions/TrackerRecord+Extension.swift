//
//  TrackerRecord+Extension.swift
//  Tracker
//
//  Created by Simon Butenko on 25.11.2024.
//

import CoreData

extension TrackerRecord {
    init(coreData: TrackerRecordCoreData) {
        self.id = coreData.id!
        self.date = coreData.date!
        self.tracker = Tracker(coreData: coreData.tracker!)
    }
}

extension TrackerRecordCoreData {
    convenience init(data: TrackerRecord, context: NSManagedObjectContext) {
        self.init(context: context)
        self.id = data.id
        self.date = data.date
        self.tracker = TrackerCoreData(data: data.tracker, context: context)
    }
}

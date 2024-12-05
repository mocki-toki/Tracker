//
//  DataProvider.swift
//  Tracker
//
//  Created by Simon Butenko on 25.11.2024.
//

import CoreData

protocol DataProviderDelegate: AnyObject {
    func dataDidChange()
}

final class DataProvider {
    private let context: NSManagedObjectContext = CoreDataStack.shared.context

    private var trackerCategoryStore: TrackerCategoryStore
    private var trackerStore: TrackerStore
    private var trackerRecordStore: TrackerRecordStore

    weak var delegate: DataProviderDelegate?

    init() {
        trackerCategoryStore = TrackerCategoryStore(context: context)
        trackerStore = TrackerStore(context: context)
        trackerRecordStore = TrackerRecordStore(context: context)

        trackerCategoryStore.delegate = self
        trackerStore.delegate = self
        trackerRecordStore.delegate = self
    }

    func getAllTrackersWithCategories() -> [TrackerCategory] {
        trackerCategoryStore.getAllCategories().map({ TrackerCategory(coreData: $0) })
    }

    func getAllRecords() -> [TrackerRecord] {
        trackerRecordStore.getAllRecords().map({ TrackerRecord(coreData: $0) })
    }

    func addTracker(_ tracker: Tracker, category: TrackerCategory) {
        let categoryCoreData =
            trackerCategoryStore.getCategory(byName: category.name)
            ?? trackerCategoryStore.addCategory(name: category.name)

        trackerStore.addTracker(
            name: tracker.name, emoji: tracker.emoji, colorName: tracker.colorName,
            schedule: tracker.schedule, categoryData: categoryCoreData)
    }

    func switchTrackerRecord(for tracker: Tracker, on date: Date) {
        if let record = trackerRecordStore.getAllRecords().first(where: {
            $0.tracker!.id == tracker.id && Calendar.current.isDate($0.date!, inSameDayAs: date)
        }) {
            trackerRecordStore.deleteRecord(record)
        } else {
            guard let trackerCoreData = trackerStore.getTracker(by: tracker.id) else { return }
            trackerRecordStore.addRecord(trackerCoreData: trackerCoreData, date: date)
        }
    }

    func addCategory(name categoryName: String) {
        trackerCategoryStore.addCategory(name: categoryName)
    }

    func deleteCategory(_ category: TrackerCategory) {
        trackerCategoryStore.deleteCategory(
            TrackerCategoryCoreData(data: category, context: context))
    }

    func updateTracker(_ tracker: Tracker, category: TrackerCategory) {
        let categoryCoreData =
            trackerCategoryStore.getCategory(byName: category.name)
            ?? trackerCategoryStore.addCategory(name: category.name)
        trackerStore.updateTracker(tracker, category: categoryCoreData)
    }

    func pinTracker(_ tracker: Tracker) {
        guard let trackerCoreData = trackerStore.getTracker(by: tracker.id) else { return }
        trackerStore.pinTracker(trackerCoreData)
    }

    func unpinTracker(_ tracker: Tracker) {
        guard let trackerCoreData = trackerStore.getTracker(by: tracker.id) else { return }
        trackerStore.unpinTracker(trackerCoreData)
    }

    func deleteTracker(_ tracker: Tracker) {
        guard let trackerCoreData = trackerStore.getTracker(by: tracker.id) else { return }
        trackerStore.deleteTracker(trackerCoreData)
    }
}

// MARK: - TrackerCategoryStoreDelegate

extension DataProvider: TrackerCategoryStoreDelegate {
    func categoriesDidChange() {
        delegate?.dataDidChange()
    }
}

// MARK: - TrackerStoreDelegate

extension DataProvider: TrackerStoreDelegate {
    func trackersDidChange() {
        delegate?.dataDidChange()
    }
}

// MARK: - TrackerRecordStoreDelegate

extension DataProvider: TrackerRecordStoreDelegate {
    func recordsDidChange() {
        delegate?.dataDidChange()
    }
}

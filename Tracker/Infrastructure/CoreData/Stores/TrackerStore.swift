//
//  TrackerStore.swift
//  Tracker
//
//  Created by Simon Butenko on 25.11.2024.
//

import CoreData

protocol TrackerStoreDelegate: AnyObject {
    func trackersDidChange()
}

final class TrackerStore: NSObject, NSFetchedResultsControllerDelegate {
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>!

    weak var delegate: TrackerStoreDelegate?

    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        setupFetchedResultsController()
    }

    private func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]

        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        fetchedResultsController.delegate = self

        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Error performing fetch: \(error)")
        }
    }

    // MARK: - NSFetchedResultsControllerDelegate

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>)
    {
        delegate?.trackersDidChange()
    }

    func getAllTrackers() -> [TrackerCoreData]? {
        return fetchedResultsController.fetchedObjects
    }

    func getTracker(by id: UUID) -> TrackerCoreData? {
        return fetchedResultsController.fetchedObjects?.first(where: { $0.id == id })
    }

    @discardableResult
    func addTracker(
        name: String, emoji: String, colorName: String, schedule: Set<Weekday>?,
        categoryData: TrackerCategoryCoreData
    ) -> TrackerCoreData {
        let tracker = TrackerCoreData(context: context)
        tracker.id = UUID()
        tracker.name = name
        tracker.emoji = emoji
        tracker.colorName = colorName
        tracker.schedule = schedule?.map { "\($0.rawValue)" }.joined(separator: ",")
        tracker.category = categoryData
        saveContext()
        return tracker
    }

    func deleteTracker(_ tracker: TrackerCoreData) {
        context.delete(tracker)
        saveContext()
    }

    private func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
}

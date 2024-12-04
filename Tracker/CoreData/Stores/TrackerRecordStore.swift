//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Simon Butenko on 25.11.2024.
//

import CoreData

protocol TrackerRecordStoreDelegate: AnyObject {
    func recordsDidChange()
}

final class TrackerRecordStore: NSObject, NSFetchedResultsControllerDelegate {
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData>!

    weak var delegate: TrackerRecordStoreDelegate?

    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        setupFetchedResultsController()
    }

    private func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> =
            TrackerRecordCoreData.fetchRequest()
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
        delegate?.recordsDidChange()
    }

    func getAllRecords() -> [TrackerRecordCoreData] {
        return fetchedResultsController.fetchedObjects ?? []
    }

    @discardableResult
    func addRecord(trackerCoreData: TrackerCoreData, date: Date) -> TrackerRecordCoreData {
        let record = TrackerRecordCoreData(context: context)
        record.id = UUID()
        record.tracker = trackerCoreData
        record.date = date
        saveContext()
        return record
    }

    func deleteRecord(_ record: TrackerRecordCoreData) {
        context.delete(record)
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

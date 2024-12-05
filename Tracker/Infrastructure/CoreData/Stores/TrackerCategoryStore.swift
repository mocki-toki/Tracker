//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Simon Butenko on 25.11.2024.
//

import CoreData

protocol TrackerCategoryStoreDelegate: AnyObject {
    func categoriesDidChange()
}

final class TrackerCategoryStore: NSObject {
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>!

    weak var delegate: TrackerCategoryStoreDelegate?

    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        setupFetchedResultsController()
    }

    private func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> =
            TrackerCategoryCoreData.fetchRequest()
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

    func getAllCategories() -> [TrackerCategoryCoreData] {
        fetchedResultsController.fetchedObjects ?? []
    }

    @discardableResult
    func addCategory(name: String) -> TrackerCategoryCoreData {
        if let existingCategory = getCategory(byName: name) {
            return existingCategory
        }
        let category = TrackerCategoryCoreData(context: context)
        category.id = UUID()
        category.name = name
        saveContext()
        return category
    }

    func updateCategory(_ category: TrackerCategoryCoreData, newName: String) {
        category.name = newName
        saveContext()
    }

    func getCategory(byName name: String) -> TrackerCategoryCoreData? {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> =
            TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", name)
        fetchRequest.fetchLimit = 1
        do {
            let categories = try context.fetch(fetchRequest)
            return categories.first
        } catch {
            print("Error fetching category by name: \(error)")
            return nil
        }
    }

    func getCategory(byId id: UUID) -> TrackerCategoryCoreData? {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> =
            TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        fetchRequest.fetchLimit = 1
        do {
            let categories = try context.fetch(fetchRequest)
            return categories.first
        } catch {
            print("Error fetching category by id: \(error)")
            return nil
        }
    }

    func deleteCategory(_ category: TrackerCategoryCoreData) {
        context.delete(category)
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

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>)
    {
        delegate?.categoriesDidChange()
    }
}

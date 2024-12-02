//
//  CoreDataStack.swift
//  Tracker
//
//  Created by Simon Butenko on 25.11.2024.
//

import CoreData

final class CoreDataStack {
    static let shared = CoreDataStack()

    let persistentContainer: NSPersistentContainer

    private init() {
        persistentContainer = NSPersistentContainer(name: "Model")
        persistentContainer.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Loading CoreData failed: \(error), \(error.userInfo)")
            }
        }
    }

    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Saving CoreData failed: \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

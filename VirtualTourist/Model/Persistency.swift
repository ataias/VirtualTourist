//
//  Persistency.swift
//  VirtualTourist
//
//  Created by Ataias Pereira Reis on 21/02/21.
//

import Foundation
import CoreData

class Persistency {
    static var persistentContainer: NSPersistentContainer = {
        // TODO if in a preview, use in memory persistance
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    static func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

//
//  Persistency.swift
//  VirtualTourist
//
//  Created by Ataias Pereira Reis on 21/02/21.
//

import Foundation
import CoreData
import UIKit

class Persistency {
    static var persistentContainer: NSPersistentContainer = {
        // TODO if in a preview, use in memory persistance
        let container = NSPersistentContainer(name: "VirtualTouristDataModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
            configureContexts(container: container)
        })
        return container
    }()

    static var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    static var backgroundContext: NSManagedObjectContext!

    private static func configureContexts(container: NSPersistentContainer) {
        backgroundContext = container.newBackgroundContext()

        container.viewContext.automaticallyMergesChangesFromParent = true
        backgroundContext.automaticallyMergesChangesFromParent = true

        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        backgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
    }

}

extension Photo {
    convenience init(context: NSManagedObjectContext, photo: Flickr.Photo, image: UIImage, pin: Pin) {
        self.init(context: context)
        self.id = photo.id
        self.farm = Int64(photo.farm)
        self.image = image.pngData()
        self.isFamily = photo.isFamily != 0
        self.isFriend = photo.isFriend != 0
        self.isPublic = photo.isPublic != 0
        self.secret = photo.secret
        self.server = photo.server
        self.title = photo.title
        self.pin = pin

    }
}

extension NSManagedObjectContext {
    func trySave() {
        if self.hasChanges {
            do {
                try self.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

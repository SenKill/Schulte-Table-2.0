//
//  CoreDataStack.swift
//  Schulte Table 2.0
//
//  Created by Serik Musaev on 12.05.2022.
//  Copyright © 2022 SenKill. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    
    static let shared = CoreDataStack(modelName: "SchulteTable")
    
    private let modelName: String
    
    init(modelName: String) {
        self.modelName = modelName
    }
    
    // Loading NSPersistentContainer only once
    private lazy var storeContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: self.modelName)
        container.loadPersistentStores { _, error in
            if let error = error as? NSError {
                print("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    func saveContext() {
        guard managedContext.hasChanges else { return }
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Unresolved error \(error), \(error.userInfo)")
        }
    }
    
    // Contact through the context
    lazy var managedContext: NSManagedObjectContext = {
        storeContainer.viewContext
    }()
}

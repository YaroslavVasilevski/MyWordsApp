import Foundation
import CoreData

class CoreDataStack {
    lazy var managedContext: NSManagedObjectContext = {

        return CoreDataStack.storeContainer.viewContext
    }()


   static var storeContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "MyWords")

        container.loadPersistentStores { _, error in
            if let error = error {
                print(error)
            }
        }

        return container
    }()

    func save() {
        guard managedContext.hasChanges else { return }
        do {
            try managedContext.save()
        } catch {
            print("I can't save it \(error) ")
        }
    }
}

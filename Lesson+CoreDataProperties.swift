import Foundation
import CoreData


extension Lesson {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Lesson> {
        return NSFetchRequest<Lesson>(entityName: "Lesson")
    }

    @NSManaged public var lesson: String?
    @NSManaged public var created: Date?
    @NSManaged public var wordArray: [String]

}

extension Lesson : Identifiable {

}

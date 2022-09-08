import Foundation

struct Object: Identifiable {
    var id = UUID()

    var name: String
    var description: String

    var type: ObjectType
    var relatedObjects = [Object]()
}

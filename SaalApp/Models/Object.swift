import Foundation

struct Object: Hashable, Identifiable {
    var id = UUID()

    var name: String
    var description: String

    var type: ObjectType
    var relatedObjects = [Object]()
}

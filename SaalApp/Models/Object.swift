import Foundation

struct Object: Identifiable, Codable {
    enum ObjectType: String, CaseIterable, Codable {
        case desk, computer, keyboard, server, employee

        var displayName: String {
           return rawValue.capitalized
        }
    }

    var id = UUID()

    var name: String
    var description: String

    var type: ObjectType
    var relatedObjects = [UUID]()
}

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

extension Object {
    static var sampleObjects: [Object] {
        var objects = [Object]()

        for _ in 1...10 {
            let type = Object.ObjectType.allCases.randomElement() ?? .desk
            let number = Int.random(in: 1...10000)
            let name = "\(type.displayName.prefix(1))\(number)"
            let description = "Created on \(Date().dateTimeString)"

            var object = Object(
                name: name,
                description: description,
                type: type
            )

            for _ in 1...3 {
                if let otherObject = objects.randomElement() {
                    object.relatedObjects.append(otherObject.id)
                }
            }

            objects.append(object)
        }

        return objects
    }
}

import Foundation

final class InMemoryObjectsRepository: ObjectsRepository {
    private var objects: [Object] = {
        var objects = [Object]()

        for idx in 1...10 {
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
    }()

    func fetchObjects(
        filter: @escaping (Object) -> Bool,
        completion: @escaping (Result<[Object], Error>) -> Void
    ) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }

            let filteredObjects = self.objects.filter(filter)
            completion(.success(filteredObjects))
        }
    }

    func deleteObject(
        _ id: UUID,
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }

            let beforeCount = self.objects.count
            self.objects.removeAll { $0.id == id }

            let result = beforeCount != self.objects.count

            completion(.success(result))
        }
    }

    func addObject(
        _ object: Object,
        completion: @escaping (Result<Object, Error>) -> Void
    ) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            self.objects.append(object)
            completion(.success(object))
        }
    }

    func updateObject(
        _ object: Object,
        completion: @escaping (Result<Object, Error>) -> Void
    ) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            let index = self.objects.firstIndex { $0.id == object.id }
            if let index = index {
                self.objects[index] = object
                completion(.success(object))
            }
        }
    }
}

import Foundation

final class InMemoryObjectsRepository: ObjectsRepository {
    private var objects: [Object] = {
        var objects = [Object]()
        var type = ObjectType(name: "test")

        for idx in 1...10 {
            objects.append(
                Object(
                    name: "object \(idx)", description: "hello", type: type
                )
            )
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
}

import Foundation

final class InMemoryObjectsRepository: ObjectsRepository {
    private var objects: [Object] = {
        var objects = [Object]()
        var type = ObjectType(name: "test")

        for idx in 1...100 {
            objects.append(
                Object(
                    name: "object \(idx)", description: "hello", type: type
                )
            )
        }

        return objects
    }()

    func fetchObjects(
        search: String?,
        completion: @escaping (Result<[Object], Error>) -> Void
    ) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }

            if let search = search {
                let objects = self.objects.filter { $0.name.contains(search) }
                completion(.success(objects))
            } else {
                completion(.success(self.objects))
            }
        }
    }

    func deleteObject(
        id: UUID,
        completion: @escaping (Result<[Object], Error>) -> Void
    ) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }

            self.objects.removeAll { $0.id == id }
            completion(.success(self.objects))
        }
    }
}

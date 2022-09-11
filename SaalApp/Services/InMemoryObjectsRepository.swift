import Foundation

final class InMemoryObjectsRepository: ObjectsRepository {
    var objects: [Object] = []

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

    func addObjects(
        _ objects: [Object],
        completion: @escaping (Result<Bool, Error>) -> Void
    ) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            self.objects.append(contentsOf: objects)
            completion(.success(true))
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

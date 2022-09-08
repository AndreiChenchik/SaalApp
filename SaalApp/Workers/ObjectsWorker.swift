import Foundation

protocol ObjectsRepository {
    func fetchObjects(
        filter: @escaping (Object) -> Bool,
        completion: @escaping (Result<[Object], Error>) -> Void
    )

    func deleteObject(
        _ id: UUID,
        completion: @escaping (Result<Bool, Error>) -> Void
    )

    func addObject(
        _ object: Object,
        completion: @escaping (Result<Object, Error>) -> Void
    )
}

struct ObjectsWorker {
    let objectsRepository: ObjectsRepository

    func fetchObjects(
        search: String?,
        completion: @escaping ([Object]) -> Void
    ) {
        let filter: (Object) -> Bool
        if let search = search {
            filter = { object in
                object.name.contains(search)
            }
        } else {
            filter = { _ in true }
        }

        objectsRepository.fetchObjects(filter: filter) { result in
            switch result {
            case .success(let objects):
                DispatchQueue.main.async {
                    completion(objects)
                }
            case .failure:
                DispatchQueue.main.async {
                    completion([])
                }
            }
        }
    }

    func deleteObject(id: UUID, completion: @escaping ([Object]) -> Void) {
        objectsRepository.deleteObject(id) { result in
            switch result {
            case .success(let isDeleted):
                if isDeleted {
                    fetchObjects(search: nil, completion: completion)
                }
            case .failure:
                break
            }
        }
    }

    func addObject(completion: @escaping ([Object]) -> Void) {
        let object = Object(
            name: "hello",
            description: "hello",
            type: ObjectType(name: "test")
        )

        objectsRepository.addObject(object) { result in
            switch result {
            case .success:
                fetchObjects(search: nil, completion: completion)
            case .failure:
                break
            }
        }
    }
}
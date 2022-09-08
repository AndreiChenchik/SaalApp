import Foundation

protocol ObjectsRepository {
    func fetchObjects(
        search: String?,
        completion: @escaping (Result<[Object], Error>) -> Void
    )

    func deleteObject(
        id: UUID,
        completion: @escaping (Result<[Object], Error>) -> Void
    )
}

struct ObjectsWorker {
    let objectsRepository: ObjectsRepository

    func fetchObjects(
        search: String?,
        completion: @escaping ([Object]) -> Void
    ) {
        objectsRepository.fetchObjects(search: search) { result in
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
        objectsRepository.deleteObject(id: id) { result in
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
}

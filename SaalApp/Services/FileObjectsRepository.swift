import Foundation

final class FileObjectsRepository: ObjectsRepository {
    enum Path: String { case main = "objects.json" }

    private var objects: [Object] {
        didSet { persistObjects(objects) }
    }
    private let filesManager: FilesService

    init(filesManager: FilesService) {
        self.filesManager = filesManager

        if
            let data = try? filesManager.read(fileNamed: Path.main.rawValue),
            let objects = try? JSONDecoder().decode([Object].self, from: data)
        {
            self.objects = objects
        } else {
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

            self.objects = objects
            persistObjects(objects)
        }
    }

    private func persistObjects(_ objects: [Object]) {
        if let data = try? JSONEncoder().encode(objects) {
            try? filesManager.save(
                fileNamed: Path.main.rawValue, data: data
            )
        }
    }

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

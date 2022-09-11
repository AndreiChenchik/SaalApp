import UIKit

protocol ObjectsListPresentationLogic {
    func present(response: ObjectsList.Response)
    func displayObject(response: ObjectsList.AddObject.Response)
}

final class ObjectsListInteractor: NSObject {
    private let presenter: ObjectsListPresentationLogic
    private let objectsWorker: ObjectsWorker

    init(
        presenter: ObjectsListPresentationLogic,
        objectsWorker: ObjectsWorker
    ) {
        self.presenter = presenter
        self.objectsWorker = objectsWorker
    }
}

// MARK: - ObjectsListBusinessLogic

extension ObjectsListInteractor: ObjectsListBusinessLogic {
    func addMock(request: ObjectsList.MockObjects.Request) {
        objectsWorker.addObjects(
            objects: Object.sampleObjects
        ) { [weak self] objects in
            self?.presenter.present(response: .init(objects: objects))
        }
    }

    func addObject(request: ObjectsList.AddObject.Request) {
        let object = Object(
            name: "",
            description: "Created at \(Date().dateTimeString)",
            type: request.type
        )

        objectsWorker.addObject(object: object) { [weak self] object in
            self?.presenter.displayObject(response: .init(objectId: object.id))
        }
    }

    func loadObjects(request: ObjectsList.LoadObjects.Request) {
        let filterText = request.filter

        let filter: (Object) -> Bool
        if let search = filterText?.trimmingCharacters(in: .whitespacesAndNewlines),
           !search.isEmpty {
            filter = { object in
                let prompt = search
                    .lowercased()

                let name = object.name.lowercased()
                let description = object.description.lowercased()
                let type = object.type.displayName.lowercased()
                let cellTitle = "\(type): \(name)"

                return (
                    name.contains(prompt)
                    || description.contains(prompt)
                    || cellTitle.contains(prompt)
                )
            }
        } else {
            filter = { _ in true }
        }

        objectsWorker.fetchObjects(filter: filter) { [weak self] objects in
            self?.presenter.present(response: .init(objects: objects))
        }
    }

    func deleteObject(request: ObjectsList.DeleteObject.Request) {
        let id = request.objectId
        objectsWorker.deleteObject(id: id) { [weak self] objects in
            self?.presenter.present(response: .init(objects: objects))
        }
    }
}

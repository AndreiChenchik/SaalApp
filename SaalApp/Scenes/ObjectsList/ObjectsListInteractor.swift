import UIKit

protocol ObjectsListPresentationLogic {
    func present(response: ObjectsList.Response)
}

final class ObjectsListInteractor: NSObject {
    let presenter: ObjectsListPresentationLogic
    let objectsWorker: ObjectsWorker

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
    typealias Response = ObjectsList.Response

    func addObject(request: ObjectsList.AddObject.Request) {
        objectsWorker.addObject { [weak self] objects in
            self?.presenter.present(response: Response(objects: objects))
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
            self?.presenter.present(response: Response(objects: objects))
        }
    }

    func deleteObject(request: ObjectsList.DeleteObject.Request) {
        let id = request.objectId
        objectsWorker.deleteObject(id: id) { [weak self] objects in
            self?.presenter.present(response: Response(objects: objects))
        }
    }
}

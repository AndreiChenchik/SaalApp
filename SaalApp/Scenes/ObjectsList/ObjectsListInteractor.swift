import UIKit

protocol ObjectsListPresentationLogic {
    func present(response: ObjectsList.GetResponse)
}

final class ObjectsListInteractor {
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
    typealias Response = ObjectsList.GetResponse

    func addObject() {
        objectsWorker.fetchObjects(search: nil) { [weak self] objects in
            self?.presenter.present(response: Response(objects: objects))
        }
    }

    func displayObjects(search: String?) {
        objectsWorker.fetchObjects(search: search) { [weak self] objects in
            self?.presenter.present(response: Response(objects: objects))
        }
    }

    func openObject(id: UUID) {
        print("selected \(id)")
    }

    func deleteObject(id: UUID) {
        objectsWorker.deleteObject(id: id) { [weak self] objects in
            self?.presenter.present(response: Response(objects: objects))
        }
    }
}

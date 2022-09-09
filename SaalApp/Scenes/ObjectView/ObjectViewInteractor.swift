import Foundation

protocol ObjectViewPresentationLogic {
    func present(response: ObjectView.GetResponse)
}

final class ObjectViewInteractor {
    let presenter: ObjectViewPresentationLogic
    let objectsWorker: ObjectsWorker

    init(
        presenter: ObjectViewPresentationLogic,
        objectsWorker: ObjectsWorker
    ) {
        self.presenter = presenter
        self.objectsWorker = objectsWorker
    }
}

// MARK: - ObjectsListBusinessLogic

extension ObjectViewInteractor: ObjectViewBusinessLogic {
    typealias Response = ObjectView.GetResponse

    func addLink() {
        print("add requested")
    }

    func displayObject(id: UUID) {
        let filter: (Object) -> Bool = { $0.id == id }
        objectsWorker.fetchObjects(filter: filter) { [weak self] objects in
            if let object = objects.first {
                self?.presenter.present(response: Response(object: object))
            }
        }
    }

    func deleteRelation(id: UUID) {
        print("time to unlink \(id)")
    }
}

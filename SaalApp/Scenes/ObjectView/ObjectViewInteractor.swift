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
            guard let self = self else { return }

            if let object = objects.first {
                let relationFilter: (Object) -> Bool = {
                    object.relatedObjects.contains($0.id)
                }

                self.objectsWorker.fetchObjects(
                    filter: relationFilter
                ) { [weak self] relatedObjects in
                    let response = Response(
                        object: object, relatedObjects: relatedObjects
                    )

                    self?.presenter.present(response: response)
                }
            }
        }
    }

    func deleteRelation(id: UUID) {
        print("time to unlink \(id)")
    }
}

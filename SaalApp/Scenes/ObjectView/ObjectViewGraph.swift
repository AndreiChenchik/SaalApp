import Foundation

struct ObjectViewGraph {
    static func getVC(
        objectId: UUID,
        objectsRepository: ObjectsRepository
    ) -> ObjectViewViewController {
        let presenter = ObjectViewPresenter()
        let objectsWorker = ObjectsWorker(objectsRepository: objectsRepository)
        let interactor = ObjectViewInteractor(
            presenter: presenter, objectsWorker: objectsWorker
        )

        let viewController = ObjectViewViewController(
            objectId: objectId, interactor: interactor
        )
        presenter.viewController = viewController

        return viewController
    }
}

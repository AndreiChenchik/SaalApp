import Foundation

struct ObjectsListGraph {
    static func getVC(
        objectsRepository: ObjectsRepository
    ) -> ObjectsListViewController {
        let presenter = ObjectsListPresenter()
        let objectsWorker = ObjectsWorker(objectsRepository: objectsRepository)
        let interactor = ObjectsListInteractor(
            presenter: presenter, objectsWorker: objectsWorker
        )

        let viewController = ObjectsListViewController(interactor: interactor)
        presenter.viewController = viewController

        return viewController
    }
}

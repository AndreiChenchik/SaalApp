import UIKit

struct ObjectsListGraph {
    static func getVC(
        objectsRepository: ObjectsRepository
    ) -> ObjectsListViewController {
        let router = ObjectsListRouter(objectsRepository: objectsRepository)
        let presenter = ObjectsListPresenter()
        let objectsWorker = ObjectsWorker(objectsRepository: objectsRepository)
        let interactor = ObjectsListInteractor(
            presenter: presenter, objectsWorker: objectsWorker
        )

        let viewController = ObjectsListViewController(
            interactor: interactor, router: router
        )

        presenter.viewController = viewController
        router.viewController = viewController

        return viewController
    }
}

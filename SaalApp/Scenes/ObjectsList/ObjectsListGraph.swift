import Foundation

struct ObjectsListGraph {
    static func getVC() -> ObjectsListViewController {
        let presenter = ObjectsListPresenter()
        let interactor = ObjectsListInteractor(presenter: presenter)
        let viewController = ObjectsListViewController(interactor: interactor)
        presenter.viewController = viewController

        return viewController
    }
}

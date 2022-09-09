import UIKit

final class ObjectsListRouter {
    weak var viewController: UIViewController?
    var objectsRepository: ObjectsRepository

    init(
        objectsRepository: ObjectsRepository,
        viewController: UIViewController? = nil
    ) {
        self.objectsRepository = objectsRepository
        self.viewController = viewController
    }
}

// MARK: - ObjectsListRoutingLogic

extension ObjectsListRouter: ObjectsListRoutingLogic {
    func openObject(id: UUID) {
        let objectViewController = ObjectViewGraph.getVC(
            objectId: id, objectsRepository: objectsRepository
        )

        if let navigationController = viewController?.navigationController {
            navigationController.pushViewController(
                objectViewController, animated: true
            )
        } else {
            viewController?.present(objectViewController, animated: true)
        }
    }
}

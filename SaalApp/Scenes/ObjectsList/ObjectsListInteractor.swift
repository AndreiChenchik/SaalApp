import UIKit

protocol ObjectsListPresentationLogic {
    func present(response: ObjectsList.GetResponse)
}

final class ObjectsListInteractor {
    var objects = [
        Object(
            name: "test",
            description: "test",
            type: ObjectType(name: "test2")
        )
    ]

    let presenter: ObjectsListPresentationLogic

    init(presenter: ObjectsListPresentationLogic) {
        self.presenter = presenter
    }
}

// MARK: - ObjectsListBusinessLogic

extension ObjectsListInteractor: ObjectsListBusinessLogic {
    typealias Response = ObjectsList.GetResponse

    func addObject() {
        objects.append(
            Object(
                name: "test3",
                description: "test",
                type: ObjectType(name: "teasdasd")
            )
        )

        presenter.present(response: Response(objects: objects))
    }

    func displayObjects(search: String?) {
        presenter.present(response: Response(objects: objects))
    }

    func openObject(id: UUID) {
        print("selected \(id)")
    }

    func deleteObject(id: UUID) {
        objects.removeAll { $0.id == id }
        presenter.present(response: Response(objects: objects))
    }
}

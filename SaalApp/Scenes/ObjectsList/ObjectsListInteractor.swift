import UIKit

protocol ObjectsListPresentationLogic {
    func present(response: ObjectsList.GetResponse)
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
    typealias Response = ObjectsList.GetResponse

    func addObject() {
        objectsWorker.addObject { [weak self] objects in
            self?.presenter.present(response: Response(objects: objects))
        }
    }

    func displayObjects(search: String?) {
        let filter: (Object) -> Bool
        if let search = search?.trimmingCharacters(in: .whitespacesAndNewlines),
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

    func openObject(id: UUID) {
        print("selected \(id)")
    }

    func deleteObject(id: UUID) {
        objectsWorker.deleteObject(id: id) { [weak self] objects in
            self?.presenter.present(response: Response(objects: objects))
        }
    }
}

// MARK: - UISearchResultsUpdating

extension ObjectsListInteractor: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if
            let prompt = searchController.searchBar.text,
            !prompt.isEmpty
        {
            displayObjects(search: prompt)
        } else {
            displayObjects(search: nil)
        }
    }
}

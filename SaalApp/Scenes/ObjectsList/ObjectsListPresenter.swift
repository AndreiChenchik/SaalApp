import UIKit

protocol ObjectsListDisplayLogic: AnyObject {
    var router: ObjectsListRoutingLogic { get }

    func displayObjects(
        viewModel: ObjectsList.ViewModel
    )
}

final class ObjectsListPresenter {
    weak var viewController: ObjectsListDisplayLogic?
}

// MARK: - ObjectsListPresentationLogic

extension ObjectsListPresenter: ObjectsListPresentationLogic {
    typealias ViewModel = ObjectsList.ViewModel
    typealias CellViewModel = ObjectsList.CellViewModel
    typealias Section = ObjectsList.ListSection

    func present(response: ObjectsList.Response) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, CellViewModel>()
        snapshot.appendSections([.main])

        let cellsData = response.objects.map(convert)
        snapshot.appendItems(cellsData)

        let viewModel = ViewModel(snapshot: snapshot)

        DispatchQueue.main.async { [weak viewController] in
            viewController?.displayObjects(viewModel: viewModel)
        }
    }

    func displayObject(response: ObjectsList.AddObject.Response) {
        DispatchQueue.main.async { [weak viewController] in
            viewController?.router.openObject(id: response.objectId)
        }
    }

    private func convert(model: Object) -> CellViewModel {
        let title = "\(model.type.displayName): \(model.name)"
        let description = "\(model.description)"

        return CellViewModel(
            id: model.id, title: title, description: description
        )
    }
}

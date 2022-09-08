import UIKit

protocol ObjectsListDisplayLogic: AnyObject {
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

    func present(response: ObjectsList.GetResponse) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, CellViewModel>()
        snapshot.appendSections([.main])

        let cellsData = response.objects.map(convert)
        snapshot.appendItems(cellsData)

        let viewModel = ViewModel(snapshot: snapshot)
        viewController?.displayObjects(viewModel: viewModel)
    }

    private func convert(model: Object) -> CellViewModel {
        CellViewModel(id: model.id, name: model.name)
    }
}

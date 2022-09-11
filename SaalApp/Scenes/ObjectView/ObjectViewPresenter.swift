import UIKit

protocol ObjectViewDisplayLogic: AnyObject {
    func displayObject(viewModel: ObjectView.ViewModel)
    func selectRelation(viewModel: ObjectView.StartAddRelation.ViewModel)
}

final class ObjectViewPresenter {
    weak var viewController: ObjectViewDisplayLogic?
}

// MARK: - ObjectViewPresentationLogic

extension ObjectViewPresenter: ObjectViewPresentationLogic {
    typealias ViewModel = ObjectView.ViewModel
    typealias CellModel = ViewModel.Cell
    typealias Section = ViewModel.Section

    func present(response: ObjectView.Response) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, CellModel>()

        snapshot.appendSections([.form])
        let formCells = convert(object: response.object)
        snapshot.appendItems(formCells)

        if !response.relatedObjects.isEmpty {
            snapshot.appendSections([.relation])
            let relationCells = convert(objects: response.relatedObjects)
            snapshot.appendItems(relationCells)
        }

        let viewModel = ViewModel(
            snapshot: snapshot,
            type: response.object.type.displayName
        )

        DispatchQueue.main.async { [weak viewController] in
            viewController?.displayObject(viewModel: viewModel)
        }
    }

    func present(response: ObjectView.StartAddRelation.Response) {
        let relations = response.allObjects.map(relation(from:))
        viewController?.selectRelation(viewModel: .init(relations: relations))
    }

    private func convert(object: Object) -> [CellModel] {
        typealias FormCellModel = CellModel.Field
        typealias FieldCategory = FormCellModel.Category

        return FieldCategory.allCases.map { category in
            let value: String

            switch category {
            case .description:
                value = object.description
            case .type:
                value = object.type.displayName

            case .name:
                value = object.name
            }

            let formCell = FormCellModel(category: category, value: value)

            return CellModel.form(formCell)
        }
    }

    private func convert(objects: [Object]) -> [CellModel] {
        typealias RelationModel = CellModel.Relation

        return objects.map { object in
            let viewModel = relation(from: object)
            return CellModel.relation(viewModel)
        }
    }

    private func relation(from object: Object) -> CellModel.Relation {
        let title = "\(object.type.displayName): \(object.name)"
        let description = "\(object.description)"

        return CellModel.Relation(
            id: object.id,
            title: title,
            description: description
        )
    }
}

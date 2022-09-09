import UIKit

protocol ObjectViewDisplayLogic: AnyObject {
    func displayObject(viewModel: ObjectView.TableViewModel)
}

final class ObjectViewPresenter {
    weak var viewController: ObjectViewDisplayLogic?
}

// MARK: - ObjectViewPresentationLogic

extension ObjectViewPresenter: ObjectViewPresentationLogic {
    typealias ViewModel = ObjectView.TableViewModel
    typealias CellViewModel = ObjectView.CellViewModel
    typealias Section = ObjectView.ListSection

    func present(response: ObjectView.GetResponse) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, CellViewModel>()

        snapshot.appendSections([.form])
        let formCells = convert(model: response.object)
        snapshot.appendItems(formCells)

        if !response.relatedObjects.isEmpty {
            snapshot.appendSections([.relation])
            let relationCells = convert(model: response.relatedObjects)
            snapshot.appendItems(relationCells)
        }

        let viewModel = ViewModel(snapshot: snapshot)

        DispatchQueue.main.async { [weak viewController] in
            viewController?.displayObject(viewModel: viewModel)
        }
    }

    private func convert(model: Object) -> [CellViewModel] {
        typealias FieldModel = ObjectView.FieldViewModel

        var formFields = [CellViewModel]()

        for field in ObjectView.FormField.allCases {
            let fieldModel: FieldModel

            switch field {
            case .description:
                fieldModel = FieldModel(
                    field: field, text: model.description
                )
            case .type:
                fieldModel = FieldModel(
                    field: field, text: model.type.displayName
                )
            case .name:
                fieldModel = FieldModel(
                    field: field, text: model.name
                )
            }

            formFields.append(.form(fieldModel))
        }

        return formFields
    }

    private func convert(model: [Object]) -> [CellViewModel] {
        typealias RelationModel = ObjectView.RelationViewModel

        return model.map { object in
            let title = "\(object.type.displayName): \(object.name)"
            let description = "\(object.description)"

            let viewModel = RelationModel(
                id: object.id,
                title: title,
                description: description
            )

            return CellViewModel.relation(viewModel)
        }
    }
}

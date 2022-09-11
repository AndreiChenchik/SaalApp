import UIKit

// MARK: Protocols

protocol ObjectViewBusinessLogic {
    func loadObject(request: ObjectView.LoadObject.Request)
    func updateField(request: ObjectView.UpdateField.Request)
    func startAddRelation(request: ObjectView.StartAddRelation.Request)
    func addRelation(request: ObjectView.AddRelation.Request)
    func removeRelation(request: ObjectView.RemoveRelation.Request)
}

// MARK: - ViewController

final class ObjectViewViewController: UIViewController {
    typealias Interactor = ObjectViewBusinessLogic

    private var interactor: Interactor

    init(interactor: Interactor) {
        self.interactor = interactor

        self.tableView = Self.configureTableView()
        self.dataSource = .init(
            tableView: tableView,
            cellProvider: cellProvider,
            onRelationDelete: Self.getRelationDeleteAction(
                interactor: interactor
            )
        )

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Navigation

    private func setupNavigation() {
        title = "Edit Object"

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Link",
            style: .plain,
            target: self,
            action: #selector(didTapLinkObject)
        )
    }

    // MARK: - TableView

    private let tableView: UITableView
    private var dataSource: ObjectViewDataSource

    private static func configureTableView() -> UITableView {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)

        tableView.register(
            ObjectTextFieldCell.self,
            forCellReuseIdentifier: ObjectTextFieldCell.identifier
        )

        tableView.register(
            ObjectRelationCell.self,
            forCellReuseIdentifier: ObjectRelationCell.identifier
        )

        tableView.register(
            ObjectTypeFieldCell.self,
            forCellReuseIdentifier: ObjectTypeFieldCell.identifier
        )

        return tableView
    }

    private func activateTableView() {
        tableView.delegate = self
        view.addSubview(tableView)
        tableView.frame = view.bounds
    }

    // MARK: - TableView: Cells

    typealias CellProvider = ObjectViewDataSource.CellProvider
    private var cellProvider: CellProvider = { tableView, indexPath, model in
        switch model {
        case .relation(let relationViewModel):
            let cell = tableView.dequeueReusableCell(
                withIdentifier: ObjectRelationCell.identifier,
                for: indexPath
            )

            cell.textLabel?.text = relationViewModel.title
            cell.detailTextLabel?.text = relationViewModel.description
            cell.selectionStyle = .none

            return cell
        case .form(let formViewModel):

            switch formViewModel.category {
            case .type:
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: ObjectTypeFieldCell.identifier,
                    for: indexPath
                )

                cell.textLabel?.text = formViewModel.category.displayName
                cell.detailTextLabel?.text = formViewModel.value
                cell.selectionStyle = .none

                return cell
            default:
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: ObjectTextFieldCell.identifier,
                    for: indexPath
                )

                if let cell = cell as? ObjectTextFieldCell {
                    cell.textLabel?.text = formViewModel.category.displayName
                    cell.textField.category = formViewModel.category
                    cell.textField.text = formViewModel.value

                    if
                        let viewController = tableView.findViewController(),
                        let delegate = viewController as? ObjectViewViewController {
                        cell.textField.delegate = delegate
                    }
                }

                return cell
            }
        }
    }
}

// MARK: - LifeCycle

extension ObjectViewViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        activateTableView()
        setupNavigation()
    }

    override func viewWillAppear(_ animated: Bool) {
        let request = ObjectView.LoadObject.Request()
        interactor.loadObject(request: request)
    }
}

// MARK: - UI Events

extension ObjectViewViewController: UITableViewDelegate, UITextFieldDelegate {
    @objc func didTapLinkObject() {
        interactor.startAddRelation(request: .init())
    }

    typealias RelationCellModel = ObjectView.ViewModel.Cell.Relation
    typealias RelationDeleteAction = (RelationCellModel) -> Void
    private static func getRelationDeleteAction(
        interactor: Interactor
    ) -> RelationDeleteAction {
        return { viewModel in
            let id = viewModel.id
            let request = ObjectView.RemoveRelation.Request(relationId: id)
            interactor.removeRelation(request: request)
        }
    }

    func tableView(
        _ tableView: UITableView, didSelectRowAt indexPath: IndexPath
    ) {
        let cell = tableView.cellForRow(at: indexPath)

        if let cell = cell as? ObjectTextFieldCell {
            cell.textField.becomeFirstResponder()
            cell.textField.selectAll(nil)
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }

    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        guard
            let textField = textField as? ObjectTextFieldCell.TextField,
            let category = textField.category,
            let value = textField.text
        else {
            return false
        }

        let request = ObjectView.UpdateField.Request(
            category: category, value: value
        )

        interactor.updateField(request: request)

        return true
    }
}

// MARK: - ObjectViewDisplayLogic

extension ObjectViewViewController: ObjectViewDisplayLogic {
    func displayObject(viewModel: ObjectView.ViewModel) {
        dataSource.apply(viewModel.snapshot, animatingDifferences: false)
    }

    func selectRelation(viewModel: ObjectView.StartAddRelation.ViewModel) {
        let relationController = RelationTableViewController(
            relations: viewModel.relations
        ) { [weak self] id in
            let request = ObjectView.AddRelation.Request(relationId: id)
            self?.interactor.addRelation(request: request)
        }

        present(relationController, animated: true)
    }
}

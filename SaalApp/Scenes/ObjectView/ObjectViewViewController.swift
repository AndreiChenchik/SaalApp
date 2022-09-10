import UIKit

// MARK: Protocols

protocol ObjectViewBusinessLogic {
    func addLink()
    func displayObject(id: UUID)
    func deleteRelation(objectId: UUID, relationId: UUID)
}

// MARK: - ViewController

final class ObjectViewViewController: UIViewController {
    typealias Interactor = ObjectViewBusinessLogic

    private var interactor: Interactor
    private var objectId: UUID

    init(objectId: UUID, interactor: Interactor) {
        self.interactor = interactor
        self.objectId = objectId

        self.tableView = Self.configureTableView()
        self.dataSource = .init(
            tableView: tableView,
            cellProvider: cellProvider,
            onRelationDelete: Self.getRelationDeleteAction(
                interactor: interactor, objectId: objectId
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
            ObjectFieldCell.self,
            forCellReuseIdentifier: ObjectFieldCell.identifier
        )

        tableView.register(
            ObjectRelationCell.self,
            forCellReuseIdentifier: ObjectRelationCell.identifier
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

            return cell
        case .form(let formViewModel):
            let cell = tableView.dequeueReusableCell(
                withIdentifier: ObjectFieldCell.identifier,
                for: indexPath
            )

            cell.textLabel?.text = formViewModel.field.displayName
            cell.detailTextLabel?.text = formViewModel.text

            return cell
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
        interactor.displayObject(id: objectId)
    }
}

// MARK: - UI Events

extension ObjectViewViewController: UITableViewDelegate {
    @objc func didTapLinkObject() {
        interactor.addLink()
    }

    typealias RelationDeleteAction = (ObjectView.RelationViewModel) -> Void
    private static func getRelationDeleteAction(
        interactor: Interactor,
        objectId: UUID
    ) -> RelationDeleteAction {
        return { viewModel in
            interactor.deleteRelation(
                objectId: objectId,
                relationId: viewModel.id
            )
        }
    }

    func tableView(
        _ tableView: UITableView, didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - ObjectViewDisplayLogic

extension ObjectViewViewController: ObjectViewDisplayLogic {
    func displayObject(viewModel: ObjectView.TableViewModel) {
        dataSource.apply(viewModel.snapshot, animatingDifferences: false)
    }
}

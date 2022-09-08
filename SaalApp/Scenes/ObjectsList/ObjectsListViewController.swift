import UIKit

protocol ObjectsListBusinessLogic {
    func addObject()
    func displayObjects(search: String?)
    func openObject(id: UUID)
    func deleteObject(id: UUID)
}

final class ObjectsListViewController: UIViewController {
    private var interactor: ObjectsListBusinessLogic

    init(interactor: ObjectsListBusinessLogic) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Navigation

    private lazy var rightBarButton = UIBarButtonItem(
        image: .add,
        style: .plain,
        target: self,
        action: #selector(didTapAddObject)
    )

    private lazy var leftBarButton = UIBarButtonItem(
        title: "Edit",
        style: .plain,
        target: self,
        action: #selector(didTapEditObjects)
    )

    // MARK: - TableView

    enum Cell: String { case id }
    private let tableView: UITableView = {
        let table = UITableView()

        table.register(
            UITableViewCell.self,
            forCellReuseIdentifier: Cell.id.rawValue
        )

        return table
    }()

    // MARK: - DataSource

    typealias Section = ObjectsList.ListSection
    typealias CellViewModel = ObjectsList.CellViewModel
    typealias DataSource = UITableViewDiffableDataSource<Section, CellViewModel>
    class TableDataSource: DataSource {
        private var interactor: ObjectsListBusinessLogic

        init(
            tableView: UITableView,
            interactor: ObjectsListBusinessLogic,
            cellProvider: @escaping DataSource.CellProvider
        ) {
            self.interactor = interactor
            super.init(tableView: tableView, cellProvider: cellProvider)
        }

        override func tableView(
            _ tableView: UITableView, canEditRowAt indexPath: IndexPath
        ) -> Bool {
            true
        }

        override func tableView(
            _ tableView: UITableView,
            commit editingStyle: UITableViewCell.EditingStyle,
            forRowAt indexPath: IndexPath
        ) {
            if editingStyle == .delete {
                if let item = itemIdentifier(for: indexPath) {
                    var snapshot = self.snapshot()
                    snapshot.deleteItems([item])
                    apply(snapshot)
                    interactor.deleteObject(id: item.id)
                }
            }
        }
    }

    private lazy var dataSource: TableDataSource = TableDataSource(
        tableView: tableView, interactor: interactor
    ) { tableView, indexPath, viewModel in
        let cell = tableView.dequeueReusableCell(
            withIdentifier: Cell.id.rawValue, for: indexPath
        )

        cell.textLabel?.text = viewModel.name

        return cell
    }
}

// MARK: - LifeCycle

extension ObjectsListViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        interactor.displayObjects(search: nil)
    }

    private func configureViews() {
        title = "Objects"

        tableView.delegate = self
        view.addSubview(tableView)
        tableView.frame = view.bounds
        navigationItem.rightBarButtonItem = rightBarButton
        navigationItem.leftBarButtonItem = leftBarButton
    }
}

// MARK: - UI Events

extension ObjectsListViewController: UITableViewDelegate {
    @objc func didTapAddObject() {
        interactor.addObject()
    }

    @objc func didTapEditObjects() {
        tableView.setEditing(!tableView.isEditing, animated: true)
        leftBarButton.title = tableView.isEditing ? "Done" : "Edit"
    }

    func tableView(
        _ tableView: UITableView, didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let item = dataSource.itemIdentifier(for: indexPath) {
            interactor.openObject(id: item.id)
        }
    }
}

// MARK: - ObjectsListDisplayLogic

extension ObjectsListViewController: ObjectsListDisplayLogic {
    func displayObjects(viewModel: ObjectsList.ViewModel) {
        dataSource.apply(viewModel.snapshot, animatingDifferences: true)
    }
}

import UIKit

protocol ObjectsListBusinessLogic {
    func addObject()
    func displayObjects(search: String?)
    func deleteObject(id: UUID)
}

protocol ObjectsListRoutingLogic {
    func openObject(id: UUID)
}

final class ObjectsListViewController: UIViewController {
    typealias Interactor = ObjectsListBusinessLogic & UISearchResultsUpdating

    private var interactor: Interactor
    private var router: ObjectsListRoutingLogic

    init(interactor: Interactor, router: ObjectsListRoutingLogic) {
        self.interactor = interactor
        self.router = router
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

    final class TableCell: UITableViewCell {
        override init(
            style: UITableViewCell.CellStyle, reuseIdentifier: String?
        ) {
            super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

    enum Cell: String { case id }
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)

        tableView.register(
            TableCell.self,
            forCellReuseIdentifier: Cell.id.rawValue
        )

        return tableView
    }()

    // MARK: - DataSource

    typealias Section = ObjectsList.ListSection
    typealias CellViewModel = ObjectsList.CellViewModel
    typealias DataSource = UITableViewDiffableDataSource<Section, CellViewModel>
    final class TableDataSource: DataSource {
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

        cell.textLabel?.text = viewModel.title
        cell.detailTextLabel?.text = viewModel.description

        return cell
    }

    // MARK: - SearchController

    private lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)

        controller.obscuresBackgroundDuringPresentation = false
        controller.searchBar.placeholder = "Filter objects..."
        controller.searchBar.sizeToFit()
        controller.searchBar.searchBarStyle = .prominent

        controller.searchResultsUpdater = interactor

        return controller
    }()
}

// MARK: - LifeCycle

extension ObjectsListViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
    }

    private func configureViews() {
        title = "Objects"

        tableView.delegate = self
        view.addSubview(tableView)
        tableView.frame = view.bounds
        navigationItem.rightBarButtonItem = rightBarButton
        navigationItem.leftBarButtonItem = leftBarButton
        navigationItem.searchController = searchController

        // swiftlint:disable:next unavailable_condition
        if #available(iOS 15, *) {} else {
            dataSource.apply(
                NSDiffableDataSourceSnapshot<Section, CellViewModel>(),
                animatingDifferences: true, completion: nil
            )
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        interactor.displayObjects(search: nil)
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
            router.openObject(id: item.id)
        }
    }
}

// MARK: - ObjectsListDisplayLogic

extension ObjectsListViewController: ObjectsListDisplayLogic {
    func displayObjects(viewModel: ObjectsList.ViewModel) {
        dataSource.apply(viewModel.snapshot, animatingDifferences: true)
    }
}

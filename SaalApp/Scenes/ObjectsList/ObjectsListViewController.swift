import UIKit

// MARK: Protocols

protocol ObjectsListBusinessLogic {
    func addObject()
    func displayObjects(search: String?)
    func deleteObject(id: UUID)
}

protocol ObjectsListRoutingLogic {
    func openObject(id: UUID)
}

// MARK: - ViewController

final class ObjectsListViewController: UIViewController {
    typealias Interactor = ObjectsListBusinessLogic & UISearchResultsUpdating

    private var interactor: Interactor
    private var router: ObjectsListRoutingLogic

    init(interactor: Interactor, router: ObjectsListRoutingLogic) {
        self.interactor = interactor
        self.router = router

        self.tableView = Self.configureTableView()
        self.dataSource = .init(
            tableView: tableView,
            cellProvider: cellProvider,
            onObjectDelete: Self.getObjectDeleteAction(interactor: interactor)
        )

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Navigation

    private func setupNavigation() {
        title = "Objects"

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Edit",
            style: .plain,
            target: self,
            action: #selector(didTapEditObjects)
        )

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: .add,
            style: .plain,
            target: self,
            action: #selector(didTapAddObject)
        )
    }

    // MARK: - SearchController

    private func setupSearch() {
        let controller = UISearchController(searchResultsController: nil)

        controller.obscuresBackgroundDuringPresentation = false
        controller.searchBar.placeholder = "Filter objects..."
        controller.searchBar.sizeToFit()
        controller.searchBar.searchBarStyle = .prominent

        controller.searchResultsUpdater = interactor

        navigationItem.searchController = controller
    }

    // MARK: - TableView

    private let tableView: UITableView
    private var dataSource: ObjectsListDataSource

    private static func configureTableView() -> UITableView {
        let tableView = UITableView(frame: .zero, style: .plain)

        tableView.register(
            ObjectsListCell.self,
            forCellReuseIdentifier: ObjectsListCell.identifier
        )

        return tableView
    }

    private func activateTableView() {
        tableView.delegate = self
        view.addSubview(tableView)
        tableView.frame = view.bounds
    }

    // MARK: - TableView: Cells

    typealias CellProvider = ObjectsListDataSource.CellProvider
    private var cellProvider: CellProvider = { tableView, indexPath, model in
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ObjectsListCell.identifier, for: indexPath
        )

        cell.textLabel?.text = model.title
        cell.detailTextLabel?.text = model.description

        return cell
    }
}

// MARK: - UI Events

extension ObjectsListViewController: UITableViewDelegate {
    typealias ObjectDeleteAction = (ObjectsList.CellViewModel) -> Void
    private static func getObjectDeleteAction(
        interactor: Interactor
    ) -> ObjectDeleteAction {
        return { viewModel in
            interactor.deleteObject(id: viewModel.id)
        }
    }

    @objc func didTapAddObject() {
        interactor.addObject()
    }

    @objc func didTapEditObjects() {
        tableView.setEditing(!tableView.isEditing, animated: true)

        let leftButton = navigationController?.navigationItem.leftBarButtonItem
        leftButton?.title = tableView.isEditing ? "Done" : "Edit"
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

// MARK: - LifeCycle

extension ObjectsListViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        activateTableView()
        setupNavigation()
        setupSearch()
    }

    override func viewWillAppear(_ animated: Bool) {
        interactor.displayObjects(search: nil)
    }
}

// MARK: - ObjectsListDisplayLogic

extension ObjectsListViewController: ObjectsListDisplayLogic {
    func displayObjects(viewModel: ObjectsList.ViewModel) {
        dataSource.apply(viewModel.snapshot, animatingDifferences: true)
    }
}

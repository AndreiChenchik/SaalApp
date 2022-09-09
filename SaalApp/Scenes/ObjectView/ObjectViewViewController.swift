import UIKit

protocol ObjectViewBusinessLogic {
      func addLink()
      func displayObject(id: UUID)
      func deleteRelation(id: UUID)
}

final class ObjectViewViewController: UIViewController {
    typealias Interactor = ObjectViewBusinessLogic

    private var interactor: Interactor
    private var objectId: UUID

    init(objectId: UUID, interactor: Interactor) {
        self.interactor = interactor
        self.objectId = objectId
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Navigation

    private lazy var rightBarButton = UIBarButtonItem(
        title: "Link",
        style: .plain,
        target: self,
        action: #selector(didTapLinkObject)
    )

    // MARK: - TableView

    class RelationCell: UITableViewCell {
        override init(
            style: UITableViewCell.CellStyle, reuseIdentifier: String?
        ) {
            super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    final class FormCell: RelationCell {}

    enum Cell: String { case form, relation }
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)

        tableView.register(
            FormCell.self,
            forCellReuseIdentifier: Cell.form.rawValue
        )

        tableView.register(
            RelationCell.self,
            forCellReuseIdentifier: Cell.relation.rawValue
        )

        return tableView
    }()

    // MARK: - DataSource

    typealias Section = ObjectView.ListSection
    typealias CellViewModel = ObjectView.CellViewModel
    typealias DataSource = UITableViewDiffableDataSource<Section, CellViewModel>
    final class TableDataSource: DataSource {
        private var interactor: Interactor

        init(
            tableView: UITableView,
            interactor: Interactor,
            cellProvider: @escaping DataSource.CellProvider
        ) {
            self.interactor = interactor
            super.init(tableView: tableView, cellProvider: cellProvider)
        }

        override func tableView(
            _ tableView: UITableView, canEditRowAt indexPath: IndexPath
        ) -> Bool {
            guard let item = itemIdentifier(for: indexPath) else {
                return false
            }

            switch item {
            case .form:
                return false
            case .relation:
                return true
            }
        }

        override func tableView(
            _ tableView: UITableView,
            commit editingStyle: UITableViewCell.EditingStyle,
            forRowAt indexPath: IndexPath
        ) {
            if editingStyle == .delete {
                if let item = itemIdentifier(for: indexPath) {
                    switch item {
                    case .relation(let relationItem):
                        var snapshot = self.snapshot()
                        snapshot.deleteItems([item])
                        apply(snapshot)
                        interactor.deleteRelation(id: relationItem.id)
                    case .form:
                        break
                    }
                }
            }
        }

        override func tableView(
            _ tableView: UITableView,
            titleForHeaderInSection section: Int
        ) -> String? {
            let tableSection = Section.allCases[section]

            switch tableSection {
            case .form:
                return nil
            case .relation:
                return "Relations"
            }
        }
    }

    private lazy var dataSource: TableDataSource = TableDataSource(
        tableView: tableView, interactor: interactor
    ) { tableView, indexPath, viewModel in
        switch viewModel {
        case .relation(let relationViewModel):
            let cell = tableView.dequeueReusableCell(
                withIdentifier: Cell.relation.rawValue, for: indexPath
            )

            cell.textLabel?.text = relationViewModel.title
            cell.detailTextLabel?.text = relationViewModel.description

            return cell
        case .form(let formViewModel):
            let cell = tableView.dequeueReusableCell(
                withIdentifier: Cell.form.rawValue, for: indexPath
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
        configureViews()
        interactor.displayObject(id: objectId)
    }

    private func configureViews() {
        title = "Edit Object"

        tableView.delegate = self
        view.addSubview(tableView)
        tableView.frame = view.bounds
        navigationItem.rightBarButtonItem = rightBarButton
    }

    override func viewWillAppear(_ animated: Bool) {
        interactor.displayObject(id: objectId)
    }
}

// MARK: - UI Events

extension ObjectViewViewController {
    @objc func didTapLinkObject() {
        interactor.addLink()
    }
}

// MARK: - UITableViewDelegate

extension ObjectViewViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView, didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - ObjectViewDisplayLogic

extension ObjectViewViewController: ObjectViewDisplayLogic {
    func displayObject(viewModel: ObjectView.TableViewModel) {
        dataSource.apply(viewModel.snapshot, animatingDifferences: true)
    }
}

import UIKit

typealias OVSection = ObjectView.ListSection
typealias OVViewModel = ObjectView.CellViewModel
typealias OVDataSource = UITableViewDiffableDataSource<OVSection, OVViewModel>

final class ObjectViewDataSource: OVDataSource {
    private var onRelationDelete: (ObjectView.RelationViewModel) -> Void

    init(
        tableView: UITableView,
        cellProvider: @escaping OVDataSource.CellProvider,
        onRelationDelete: @escaping (ObjectView.RelationViewModel) -> Void
    ) {
        self.onRelationDelete = onRelationDelete
        super.init(tableView: tableView, cellProvider: cellProvider)
    }

    // MARK: - UI Headers

    override func tableView(
        _ tableView: UITableView,
        titleForHeaderInSection section: Int
    ) -> String? {
        let tableSection = OVSection.allCases[section]

        switch tableSection {
        case .form:
            return nil
        case .relation:
            return "Relations"
        }
    }

    // MARK: - Table Editing

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
                    onRelationDelete(relationItem)
                case .form:
                    break
                }
            }
        }
    }
}

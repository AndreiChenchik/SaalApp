import UIKit

typealias OLSection = ObjectsList.ListSection
typealias OLViewModel = ObjectsList.CellViewModel
typealias OLDataSource = UITableViewDiffableDataSource<OLSection, OLViewModel>

final class ObjectsListDataSource: OLDataSource {
    init(
        tableView: UITableView,
        cellProvider: @escaping OLDataSource.CellProvider,
        onObjectDelete: @escaping (OLViewModel) -> Void
    ) {
        self.onObjectDelete = onObjectDelete
        super.init(tableView: tableView, cellProvider: cellProvider)
    }

    private var onObjectDelete: (OLViewModel) -> Void

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
                onObjectDelete(item)
            }
        }
    }
}

import UIKit

typealias OLDataSource = UITableViewDiffableDataSource<
    ObjectsList.ViewModel.Section,
    ObjectsList.ViewModel.Cell
>

final class ObjectsListDataSource: OLDataSource {
    init(
        tableView: UITableView,
        cellProvider: @escaping OLDataSource.CellProvider,
        onObjectDelete: @escaping (ObjectsList.ViewModel.Cell) -> Void
    ) {
        self.onObjectDelete = onObjectDelete
        super.init(tableView: tableView, cellProvider: cellProvider)
    }

    private var onObjectDelete: (ObjectsList.ViewModel.Cell) -> Void

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

import UIKit

final class RelationTableViewController: UITableViewController {
    typealias RelationModel = ObjectView.ViewModel.Cell.Relation
    let relations: [RelationModel]
    let completion: (UUID) -> Void

    init(relations: [RelationModel], completion: @escaping (UUID) -> Void) {
        self.relations = relations
        self.completion = completion

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        title = "Select related object"

        tableView.register(
            ObjectRelationCell.self,
            forCellReuseIdentifier: ObjectRelationCell.identifier
        )
    }

    override func tableView(
        _ tableView: UITableView, numberOfRowsInSection section: Int
    ) -> Int {
        relations.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ObjectRelationCell.identifier, for: indexPath
        )

        let relation = relations[indexPath.row]

        cell.textLabel?.text = relation.title
        cell.detailTextLabel?.text = relation.description

        return cell
    }

    override func tableView(
        _ tableView: UITableView, didSelectRowAt indexPath: IndexPath
    ) {
        completion(relations[indexPath.row].id)
        dismiss(animated: true)
    }
}

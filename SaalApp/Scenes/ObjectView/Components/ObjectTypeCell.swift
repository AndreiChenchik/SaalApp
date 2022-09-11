import UIKit

final class ObjectTypeFieldCell: UITableViewCell {
    static let identifier = "typeCell"

    override init(
        style: UITableViewCell.CellStyle, reuseIdentifier: String?
    ) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

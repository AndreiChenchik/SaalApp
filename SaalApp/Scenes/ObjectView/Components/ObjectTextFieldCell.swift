import UIKit

final class ObjectTextFieldCell: UITableViewCell {
    static let identifier = "textFieldCell"

    final class TextField: UITextField {
        var category: ObjectView.ViewModel.Cell.Field.Category?
    }

    let textField: TextField

    override init(
        style: UITableViewCell.CellStyle, reuseIdentifier: String?
    ) {
        textField = TextField()
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)

        setupTextField()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Helpers

extension ObjectTextFieldCell {
    private func setupTextField() {
        if let detailTextLabel = detailTextLabel, let textLabel = textLabel {
            textField.font = detailTextLabel.font
            textField.textAlignment = detailTextLabel.textAlignment

            contentView.addSubview(textField)

            textField.translatesAutoresizingMaskIntoConstraints = false

            contentView.addConstraints([
                textField.centerYAnchor.constraint(
                    equalTo: contentView.centerYAnchor
                ),
                textField.trailingAnchor.constraint(
                    equalTo: contentView.layoutMarginsGuide.trailingAnchor
                ),
                textField.leadingAnchor.constraint(
                    equalTo: textLabel.trailingAnchor,
                    constant: 5
                )
            ])
        }
    }
}

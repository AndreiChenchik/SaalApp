import UIKit

// swiftlint:disable nesting
enum ObjectView {

    // MARK: Use Cases

    enum LoadObject {
        struct Request {}
    }

    enum UpdateField {
        struct Request {
            let category: ViewModel.Cell.Field.Category
            let value: String
        }
    }

    enum StartAddRelation {
        struct Request {}

        struct Response {
            let allObjects: [Object]
        }

        struct ViewModel {
            let relations: [ObjectView.ViewModel.Cell.Relation]
        }
    }

    enum AddRelation {
        struct Request {
            let relationId: UUID
        }
    }

    enum RemoveRelation {
        struct Request {
            let relationId: UUID
        }
    }

    struct Response {
        let object: Object
        let relatedObjects: [Object]
    }

    struct ViewModel {
        enum Section: String, CaseIterable { case form, relation }

        enum Cell: Hashable {
            struct Relation: Hashable, Identifiable {
                let id: UUID
                let title: String
                let description: String
            }

            struct Field: Hashable {
                enum Category: String, Hashable, CaseIterable {
                    case type, name, description

                    var displayName: String {
                       return rawValue.capitalized
                    }
                }

                let category: Category
                let value: String
            }

            case form(Field)
            case relation(Relation)
        }

        let snapshot: NSDiffableDataSourceSnapshot<Section, Cell>
        let type: String
    }
}

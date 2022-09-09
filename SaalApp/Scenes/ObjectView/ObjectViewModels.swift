import UIKit

enum ObjectView {
    struct GetRequest {
        let objectId: UUID
    }

    struct GetResponse {
        let object: Object
        var relatedObjects = [Object]()
    }

    struct RelationViewModel: Hashable, Identifiable {
        let id: UUID
        let title: String
        let description: String
    }

    enum FormField: String, Hashable, CaseIterable {
        case type, name, description

        var displayName: String {
           return rawValue.capitalized
        }
    }

    struct FieldViewModel: Hashable {
        let field: FormField
        let text: String
    }

    enum CellViewModel: Hashable {
        case form(FieldViewModel)
        case relation(RelationViewModel)
    }

    enum ListSection: CaseIterable { case form, relation }
    struct TableViewModel {
        let snapshot: NSDiffableDataSourceSnapshot<ListSection, CellViewModel>
    }
}

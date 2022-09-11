import UIKit

// swiftlint:disable nesting
enum ObjectsList {

    // MARK: Use Cases

    enum AddObject {
        struct Request {
            let type: Object.ObjectType
        }

        struct Response {
            let objectId: UUID
        }
    }

    enum MockObjects {
        struct Request {}
    }

    enum LoadObjects {
        struct Request {
            let filter: String?
        }
    }

    enum DeleteObject {
        struct Request {
            let objectId: UUID
        }
    }

    struct Response {
        let objects: [Object]
    }

    struct CellViewModel: Hashable, Identifiable {
        let id: UUID
        let title: String
        let description: String
    }

    enum ListSection { case main }
    struct ViewModel {
        let snapshot: NSDiffableDataSourceSnapshot<ListSection, CellViewModel>
    }
}

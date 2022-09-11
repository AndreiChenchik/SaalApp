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

    struct ViewModel {
        enum Section { case main }

        struct Cell: Hashable, Identifiable {
            let id: UUID
            let title: String
            let description: String
        }

        let snapshot: NSDiffableDataSourceSnapshot<Section, Cell>
    }
}

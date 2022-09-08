import UIKit

enum ObjectsList {
    struct GetRequest {
        let search: String?
    }

    struct GetResponse {
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

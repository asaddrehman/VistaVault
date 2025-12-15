import Combine
import Foundation

/// Protocol for ViewModels that fetch data from remote sources
protocol FetchableViewModel: ObservableObject {
    associatedtype DataType

    var isLoading: Bool { get set }
    var errorMessage: String? { get set }

    func fetchData() async
}

/// Protocol for ViewModels that manage CRUD operations
protocol CRUDViewModel: FetchableViewModel {
    associatedtype ItemType: Identifiable

    var items: [ItemType] { get set }

    func create(_ item: ItemType) async throws
    func update(_ item: ItemType) async throws
    func delete(_ item: ItemType) async throws
}

/// Protocol for ViewModels that support search/filtering
protocol SearchableViewModel: ObservableObject {
    associatedtype ItemType

    var searchText: String { get set }
    var filteredItems: [ItemType] { get }
}

/// Protocol for ViewModels that support pagination
protocol PaginatedViewModel: FetchableViewModel {
    var currentPage: Int { get set }
    var hasMorePages: Bool { get }

    func loadNextPage() async
}

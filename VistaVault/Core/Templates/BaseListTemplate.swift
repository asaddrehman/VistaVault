import SwiftUI

/// Generic list view template for displaying collections of items
struct BaseListTemplate<Item: Identifiable, RowContent: View>: View {
    let items: [Item]
    let isLoading: Bool
    let emptyStateTitle: String
    let emptyStateIcon: String
    let rowContent: (Item) -> RowContent

    var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if items.isEmpty {
                ContentUnavailableView(
                    emptyStateTitle,
                    systemImage: emptyStateIcon,
                    description: Text("No items to display")
                )
            } else {
                List(items) { item in
                    rowContent(item)
                }
                .listStyle(.insetGrouped)
            }
        }
    }
}

/// Search-enabled list view template
struct SearchableListTemplate<Item: Identifiable, RowContent: View>: View {
    let items: [Item]
    let isLoading: Bool
    let searchText: Binding<String>
    let emptyStateTitle: String
    let emptyStateIcon: String
    let rowContent: (Item) -> RowContent

    var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if items.isEmpty {
                ContentUnavailableView(
                    emptyStateTitle,
                    systemImage: emptyStateIcon,
                    description: Text("No items found")
                )
            } else {
                List(items) { item in
                    rowContent(item)
                }
                .listStyle(.insetGrouped)
                .searchable(text: searchText, prompt: "Search...")
            }
        }
    }
}

import SwiftUI

struct InventoryView: View {
    @StateObject var inventoryVM = InventoryViewModel()
    @StateObject var unitsVM = UnitsViewModel()
    @State private var showingDetail = false
    @State private var selectedItem: InventoryItem?
    @State private var searchText = ""
    private let brandPrimary = Color("brandPrimary")
    private let brandSecondary = Color("brandSecondary")

    var filteredItems: [InventoryItem] {
        if searchText.isEmpty {
            return inventoryVM.items
        }
        return inventoryVM.items.filter {
            $0.displayName.localizedCaseInsensitiveContains(searchText) ||
                $0.productCode.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if inventoryVM.isLoading {
                    ProgressView("Loading Inventory...")
                        .controlSize(.large)
                } else if filteredItems.isEmpty {
                    emptyStateView
                } else {
                    inventoryList
                }
            }
            .navigationTitle("Inventory")
            .toolbar { toolbarItems }
            .searchable(text: $searchText, prompt: "Search items or codes...")
            .sheet(isPresented: $showingDetail) {
                InventoryDetailView(vm: inventoryVM, unitsVM: unitsVM, item: $selectedItem)
            }
            .background(Color(.systemGroupedBackground))
            .onAppear { unitsVM.setupListener() }
        }
    }

    private var inventoryList: some View {
        List {
            ForEach(filteredItems) { item in
                InventoryRow(item: item, units: unitsVM.units)
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            deleteItem(item)
                        } label: {
                            Label("Delete", systemImage: "trash.fill")
                        }

                        Button {
                            selectedItem = item
                            showingDetail.toggle()
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        .tint(brandSecondary)
                    }
                    .listRowSeparator(.hidden)
                    .listRowInsets(.init(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .listRowBackground(Color.clear)
                    .onTapGesture {
                        selectedItem = item
                        showingDetail.toggle()
                    }
            }
        }
        .listStyle(.plain)
        .refreshable { inventoryVM.refreshData() }
        .background(Color(.systemGroupedBackground))
    }

    private var emptyStateView: some View {
        ContentUnavailableView(
            label: {
                VStack {
                    Image(systemName: "cube.box.fill")
                        .font(.system(size: 48))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(brandSecondary.gradient)
                        .padding(.bottom, 8)
                    Text("No Inventory Items")
                }
            },
            description: {
                Text("Get started by adding your first inventory item")
                    .foregroundColor(.secondary)
            },
            actions: {
                Button {
                    selectedItem = nil
                    showingDetail.toggle()
                } label: {
                    Label("Add Item", systemImage: "plus")
                }
                .buttonStyle(.borderedProminent)
                .tint(brandSecondary)
            }
        )
    }

    private var toolbarItems: some ToolbarContent {
        ToolbarItemGroup(placement: .primaryAction) {
            Button {
                selectedItem = nil
                showingDetail.toggle()
            } label: {
                Image(systemName: "plus")
                    .font(.headline)
            }

            Menu {
                NavigationLink {
                    UnitListView()
                } label: {
                    Label("Manage Units", systemImage: "ruler.fill")
                }
                
                NavigationLink {
                    ValuationClassListView()
                } label: {
                    Label("Valuation Classes", systemImage: "tag.fill")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
            }
        }
    }

    private func deleteItem(_ item: InventoryItem) {
        _ = withAnimation(.spring()) {
            inventoryVM.deleteItem(item)
        }
    }
}

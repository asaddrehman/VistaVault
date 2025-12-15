import Foundation

@MainActor
class InventoryViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var items = [InventoryItem]()
    @Published var isLoading = false
    @Published var errorMessage = ""

    // MARK: - Dependencies

    private let inventoryService = InventoryService.shared
    private let authManager = LocalAuthManager.shared

    // MARK: - Initialization

    init() {
        refreshData()
    }

    deinit { }

    // MARK: - CRUD Operations

    func addItem(_ item: InventoryItem, batch _: Any? = nil) -> Result<Void, Error> {
        Task {
            do {
                try await inventoryService.createInventoryItem(item)
                refreshData()
            } catch {
                handleError("Add failed: \(error.localizedDescription)")
            }
        }
        return .success(())
    }

    func updateItem(_ item: InventoryItem, batch _: Any? = nil) -> Result<Void, Error> {
        Task {
            do {
                try await inventoryService.updateInventoryItem(item)
                refreshData()
            } catch {
                handleError("Update failed: \(error.localizedDescription)")
            }
        }
        return .success(())
    }

    func deleteItem(_ item: InventoryItem, batch _: Any? = nil) -> Result<Void, Error> {
        guard let itemId = item.id else {
            return .failure(NSError(domain: "Inventory", code: 400))
        }

        Task {
            do {
                try await inventoryService.deleteInventoryItem(id: itemId)
                refreshData()
            } catch {
                handleError("Delete failed: \(error.localizedDescription)")
            }
        }
        return .success(())
    }

    // MARK: - Data Handling

    func refreshData() {
        isLoading = true

        Task {
            do {
                let fetchedItems = try await inventoryService.fetchInventoryItems()
                await MainActor.run {
                    self.items = fetchedItems
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    handleError("Fetch error: \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: - Validation

    struct InventoryInputs {
        let productCode: String
        let name: String
        let displayName: String
        let description: String
        let unitId: String
        let valuationClassId: String?
        let salesPrice: String
        let purchasePrice: String
        let quantity: String
    }

    func validateInputs(_ inputs: InventoryInputs) -> InventoryItem? {
        guard !inputs.productCode.isEmpty else {
            handleError("Product code required")
            return nil
        }

        guard !inputs.name.isEmpty else {
            handleError("Internal name required")
            return nil
        }

        guard !inputs.displayName.isEmpty else {
            handleError("Display name required")
            return nil
        }

        guard let sales = Double(inputs.salesPrice), sales >= 0 else {
            handleError("Invalid sales price")
            return nil
        }

        guard let purchase = Double(inputs.purchasePrice), purchase >= 0 else {
            handleError("Invalid purchase price")
            return nil
        }

        guard let quantity = Int(inputs.quantity), quantity >= 0 else {
            handleError("Invalid quantity")
            return nil
        }

        return InventoryItem(
            productCode: inputs.productCode,
            name: inputs.name,
            description: inputs.description,
            displayName: inputs.displayName,
            unitId: inputs.unitId,
            valuationClassId: inputs.valuationClassId,
            salesPrice: sales,
            purchasePrice: purchase,
            availableQuantity: quantity
        )
    }

    // MARK: - Error Handling

    private func handleError(_ message: String) {
        errorMessage = message
        isLoading = false
    }
}

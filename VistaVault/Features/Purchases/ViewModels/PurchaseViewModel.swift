import Combine
import Foundation

@MainActor
class PurchaseViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var purchases: [Purchase] = []
    @Published var filteredPurchases: [Purchase] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText = ""
    @Published var selectedStatus: Purchase.PurchaseStatus?
    @Published var selectedVendor: String?

    // MARK: - Dependencies

    private let service: PurchaseService
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Computed Properties

    var totalPurchases: Double {
        purchases.reduce(0) { $0 + $1.totalAmount }
    }

    var totalPaid: Double {
        purchases.reduce(0) { $0 + $1.paidAmount }
    }

    var totalBalance: Double {
        purchases.reduce(0) { $0 + $1.balanceAmount }
    }

    // MARK: - Initialization

    init(service: PurchaseService = PurchaseService.shared) {
        self.service = service
        setupSearchAndFilters()
    }

    // MARK: - Search and Filter

    private func setupSearchAndFilters() {
        Publishers.CombineLatest3($purchases, $searchText, $selectedStatus)
            .map { purchases, searchText, status in
                var filtered = purchases

                // Filter by status
                if let status {
                    filtered = filtered.filter { $0.status == status }
                }

                // Filter by search text
                if !searchText.isEmpty {
                    filtered = filtered.filter {
                        $0.purchaseNumber.localizedCaseInsensitiveContains(searchText) ||
                            $0.vendorName.localizedCaseInsensitiveContains(searchText) ||
                            $0.referenceNumber?.localizedCaseInsensitiveContains(searchText) == true
                    }
                }

                return filtered
            }
            .assign(to: &$filteredPurchases)
    }

    // MARK: - CRUD Operations

    func fetchPurchases() async {
        isLoading = true
        errorMessage = nil

        do {
            purchases = try await service.fetchAll()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func fetchByVendor(_ vendorId: String) async {
        isLoading = true
        errorMessage = nil

        do {
            purchases = try await service.fetchByVendor(vendorId: vendorId)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func createPurchase(_ purchase: Purchase) async -> Bool {
        isLoading = true
        errorMessage = nil

        do {
            _ = try await service.create(purchase)
            await fetchPurchases()
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }

    func updatePurchase(_ purchase: Purchase) async -> Bool {
        isLoading = true
        errorMessage = nil

        do {
            try await service.update(purchase)
            await fetchPurchases()
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }

    func deletePurchase(_ purchase: Purchase) async -> Bool {
        guard let id = purchase.id else { return false }

        isLoading = true
        errorMessage = nil

        do {
            try await service.delete(id: id)
            await fetchPurchases()
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }

    func generatePurchaseNumber() async -> String {
        do {
            return try await service.generatePurchaseNumber()
        } catch {
            errorMessage = error.localizedDescription
            return "INV-AP-00001"
        }
    }

    func recordPayment(for purchase: Purchase, amount: Double) async -> Bool {
        guard let id = purchase.id else { return false }

        isLoading = true
        errorMessage = nil

        do {
            try await service.updatePayment(purchaseId: id, amount: amount)
            await fetchPurchases()
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }

    // MARK: - Helper Methods

    func calculateTotals(for items: [PurchaseItem]) -> PurchaseService.PurchaseTotals {
        service.calculateTotals(for: items)
    }

    func clearError() {
        errorMessage = nil
    }
}

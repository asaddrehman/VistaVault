import Combine
import Foundation

@MainActor
class SaleViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var sales: [Sale] = []
    @Published var filteredSales: [Sale] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText = ""
    @Published var selectedStatus: Sale.SaleStatus?
    @Published var selectedCustomer: String?

    // MARK: - Dependencies

    private let service: SaleService
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Computed Properties

    var totalSales: Double {
        sales.reduce(0) { $0 + $1.totalAmount }
    }

    var totalPaid: Double {
        sales.reduce(0) { $0 + $1.paidAmount }
    }

    var totalBalance: Double {
        sales.reduce(0) { $0 + $1.balanceAmount }
    }

    // MARK: - Initialization

    init(service: SaleService = SaleService.shared) {
        self.service = service
        setupSearchAndFilters()
    }

    // MARK: - Search and Filter

    private func setupSearchAndFilters() {
        Publishers.CombineLatest3($sales, $searchText, $selectedStatus)
            .map { sales, searchText, status in
                var filtered = sales

                // Filter by status
                if let status {
                    filtered = filtered.filter { $0.status == status }
                }

                // Filter by search text
                if !searchText.isEmpty {
                    filtered = filtered.filter {
                        $0.saleNumber.localizedCaseInsensitiveContains(searchText) ||
                            $0.customerName.localizedCaseInsensitiveContains(searchText) ||
                            $0.referenceNumber?.localizedCaseInsensitiveContains(searchText) == true
                    }
                }

                return filtered
            }
            .assign(to: &$filteredSales)
    }

    // MARK: - CRUD Operations

    func fetchSales() async {
        isLoading = true
        errorMessage = nil

        do {
            sales = try await service.fetchAll()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func fetchByCustomer(_ customerId: String) async {
        isLoading = true
        errorMessage = nil

        do {
            sales = try await service.fetchByCustomer(customerId: customerId)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func createSale(_ sale: Sale) async -> Bool {
        isLoading = true
        errorMessage = nil

        do {
            _ = try await service.create(sale)
            await fetchSales()
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }

    func updateSale(_ sale: Sale) async -> Bool {
        isLoading = true
        errorMessage = nil

        do {
            try await service.update(sale)
            await fetchSales()
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }

    func deleteSale(_ sale: Sale) async -> Bool {
        guard let id = sale.id else { return false }

        isLoading = true
        errorMessage = nil

        do {
            try await service.delete(id: id)
            await fetchSales()
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }

    func generateSaleNumber() async -> String {
        do {
            return try await service.generateSaleNumber()
        } catch {
            errorMessage = error.localizedDescription
            return "INV-AR-00001"
        }
    }

    func recordPayment(for sale: Sale, amount: Double) async -> Bool {
        guard let id = sale.id else { return false }

        isLoading = true
        errorMessage = nil

        do {
            try await service.updatePayment(saleId: id, amount: amount)
            await fetchSales()
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }

    func updateShippingStatus(for sale: Sale, status: Sale.SaleStatus) async -> Bool {
        guard let id = sale.id else { return false }

        isLoading = true
        errorMessage = nil

        do {
            try await service.updateShippingStatus(saleId: id, status: status)
            await fetchSales()
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }

    // MARK: - Helper Methods

    func calculateTotals(for items: [SaleItem]) -> SaleService.SaleTotals {
        service.calculateTotals(for: items)
    }

    func clearError() {
        errorMessage = nil
    }
}

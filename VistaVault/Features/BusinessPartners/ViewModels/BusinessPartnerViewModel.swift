import Foundation

@MainActor
class BusinessPartnerViewModel: ObservableObject {
    @Published var partners: [BusinessPartner] = []
    @Published var filteredPartners: [BusinessPartner] = []
    @Published var searchText: String = ""
    @Published var selectedType: BusinessPartner.PartnerType?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let service = BusinessPartnerService.shared

    // MARK: - Computed Properties

    var customers: [BusinessPartner] {
        partners.filter(\.isCustomer)
    }

    var filteredCustomers: [BusinessPartner] {
        filteredPartners.filter(\.isCustomer)
    }

    var vendors: [BusinessPartner] {
        partners.filter(\.isVendor)
    }

    var activePartners: [BusinessPartner] {
        partners.filter(\.isActive)
    }

    // MARK: - Fetch Partners

    func fetchPartners(userId: String) {
        Task {
            isLoading = true
            errorMessage = nil

            do {
                partners = try await service.fetchPartners(userId: userId)
                applyFilters()
            } catch {
                errorMessage = error.localizedDescription
            }

            isLoading = false
        }
    }

    // MARK: - Create Partner

    func createPartner(_ partner: BusinessPartner) async throws {
        // Validate before creating
        let validationResult = service.validatePartner(partner)
        switch validationResult {
        case .success:
            try await service.createPartner(partner)
            fetchPartners(userId: partner.userId)
        case .failure(let error):
            throw error
        }
    }

    // MARK: - Update Partner

    func updatePartner(_ partner: BusinessPartner) async throws {
        // Validate before updating
        let validationResult = service.validatePartner(partner)
        switch validationResult {
        case .success:
            try await service.updatePartner(partner)
            fetchPartners(userId: partner.userId)
        case .failure(let error):
            throw error
        }
    }

    // MARK: - Delete Partner

    func deletePartner(_ partner: BusinessPartner) async throws {
        guard let id = partner.id else {
            throw AppError.dataNotFound
        }

        try await service.deletePartner(id: id)
        fetchPartners(userId: partner.userId)
    }

    // MARK: - Search and Filter

    func applyFilters() {
        var result = service.filterPartners(partners, by: selectedType)
        result = service.searchPartners(result, searchText: searchText)
        filteredPartners = result
    }

    // MARK: - Helper Methods

    func getPartner(by id: String) -> BusinessPartner? {
        partners.first { $0.id == id }
    }

    func generatePartnerCode(type: BusinessPartner.PartnerType) -> String {
        service.generatePartnerCode(type: type, existingPartners: partners)
    }
}

import Foundation

@MainActor
class ValuationClassViewModel: ObservableObject {
    @Published var valuationClasses = [ValuationClass]()
    @Published var isLoading = false
    @Published var errorMessage = ""
    
    private let inventoryService = InventoryService.shared
    private let authManager = LocalAuthManager.shared
    
    init() {
        refreshData()
    }
    
    // MARK: - CRUD Operations
    
    func createValuationClass(_ valuationClass: ValuationClass) async throws {
        try await inventoryService.createValuationClass(valuationClass)
        refreshData()
    }
    
    func updateValuationClass(_ valuationClass: ValuationClass) async throws {
        try await inventoryService.updateValuationClass(valuationClass)
        refreshData()
    }
    
    func deleteValuationClass(_ valuationClass: ValuationClass) async throws {
        guard let id = valuationClass.id else {
            throw AppError.dataNotFound
        }
        try await inventoryService.deleteValuationClass(id: id)
        refreshData()
    }
    
    // MARK: - Data Handling
    
    func refreshData() {
        isLoading = true
        
        Task {
            do {
                let fetchedClasses = try await inventoryService.fetchValuationClasses()
                await MainActor.run {
                    self.valuationClasses = fetchedClasses
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    handleError("Fetch error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    func generateClassCode() -> String {
        let maxNumber = valuationClasses.compactMap { classItem -> Int? in
            let components = classItem.classCode.components(separatedBy: "-")
            return components.last.flatMap { Int($0) }
        }.max() ?? 0
        
        return "VC-\(String(format: "%04d", maxNumber + 1))"
    }
    
    // MARK: - Error Handling
    
    private func handleError(_ message: String) {
        errorMessage = message
        isLoading = false
    }
}

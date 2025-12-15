import Foundation

@MainActor
class UnitsViewModel: ObservableObject {
    @Published var units = [Unit]()
    @Published var errorMessage = ""

    private let inventoryService = InventoryService.shared
    private let authManager = LocalAuthManager.shared

    func setupListener() {
        Task {
            await fetchUnits()
        }
    }

    func fetchUnits() async {
        do {
            let fetchedUnits = try await inventoryService.fetchUnits()
            units = fetchedUnits
        } catch {
            errorMessage = "Units error: \(error.localizedDescription)"
        }
    }

    func addUnit(_ unit: Unit) {
        Task {
            do {
                try await inventoryService.createUnit(unit)
                await fetchUnits()
            } catch {
                errorMessage = "Add error: \(error.localizedDescription)"
            }
        }
    }

    func updateUnit(_ unit: Unit, name: String, description: String) {
        guard let unitId = unit.id else {
            errorMessage = "Invalid unit selection"
            return
        }

        let updatedUnit = Unit(
            id: unitId,
            name: name,
            description: description,
            created: Date()
        )

        Task {
            do {
                try await inventoryService.updateUnit(updatedUnit)
                await fetchUnits()
            } catch {
                errorMessage = "Update failed: \(error.localizedDescription)"
            }
        }
    }

    func deleteUnit(_ unit: Unit) {
        guard let unitId = unit.id else {
            errorMessage = "Invalid unit selection"
            return
        }

        Task {
            do {
                try await inventoryService.deleteUnit(id: unitId)
                await fetchUnits()
            } catch {
                errorMessage = "Delete failed: \(error.localizedDescription)"
            }
        }
    }

    deinit { }
}

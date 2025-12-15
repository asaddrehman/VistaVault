import Foundation
import GRDB

@MainActor
class InventoryService {
    static let shared = InventoryService()

    private let dataController = DataController.shared
    private let authManager = LocalAuthManager.shared

    private init() { }

    // MARK: - Inventory Items

    func fetchInventoryItems() async throws -> [InventoryItem] {
        guard let userId = authManager.currentUserId else {
            throw AppError.authenticationRequired
        }

        let itemsData = try await dataController.dbQueue.read { db in
            try InventoryItemData
                .filter(Column("userId") == userId)
                .order(Column("name"))
                .fetchAll(db)
        }
        return itemsData.map { InventoryItem(from: $0) }
    }

    func createInventoryItem(_ item: InventoryItem) async throws {
        guard let userId = authManager.currentUserId else {
            throw AppError.authenticationRequired
        }

        // Fetch user
        guard let user = try dataController.fetchUser(byId: userId) else {
            throw AppError.dataNotFound
        }

        var itemData = item.toData()
        itemData.userId = userId
        
        try await dataController.dbQueue.write { db in
            try itemData.insert(db)
        }
    }

    func updateInventoryItem(_ item: InventoryItem) async throws {
        guard let id = item.id else {
            throw AppError.dataNotFound
        }

        try await dataController.dbQueue.write { db in
            guard var itemData = try InventoryItemData
                .filter(Column("id") == id)
                .fetchOne(db) else {
                throw AppError.dataNotFound
            }

            itemData.productCode = item.productCode
            itemData.name = item.name
            itemData.itemDescription = item.description
            itemData.displayName = item.displayName
            itemData.unitId = item.unitId
            itemData.valuationClassId = item.valuationClassId
            itemData.salesPrice = item.salesPrice
            itemData.purchasePrice = item.purchasePrice
            itemData.availableQuantity = item.availableQuantity
            itemData.timestamp = item.timestamp

            try itemData.update(db)
        }
    }

    func deleteInventoryItem(id: String) async throws {
        let itemData = try await dataController.dbQueue.read { db in
            try InventoryItemData
                .filter(Column("id") == id)
                .fetchOne(db)
        }

        try await dataController.dbQueue.write { db in
            try InventoryItemData
                .filter(Column("id") == id)
                .deleteAll(db)
        }
    }

    // MARK: - Units

    func fetchUnits() async throws -> [Unit] {
        guard let userId = authManager.currentUserId else {
            throw AppError.authenticationRequired
        }

        let unitsData = try await dataController.dbQueue.read { db in
            try UnitData
                .filter(Column("userId") == userId)
                .order(Column("name"))
                .fetchAll(db)
        }
        return unitsData.map { Unit(from: $0) }
    }

    func createUnit(_ unit: Unit) async throws {
        guard let userId = authManager.currentUserId else {
            throw AppError.authenticationRequired
        }

        // Fetch user
        guard let user = try dataController.fetchUser(byId: userId) else {
            throw AppError.dataNotFound
        }

        var unitData = unit.toData()
        unitData.userId = userId
        
        try await dataController.dbQueue.write { db in
            try unitData.insert(db)
        }
    }

    func updateUnit(_ unit: Unit) async throws {
        guard let id = unit.id else {
            throw AppError.dataNotFound
        }

        try await dataController.dbQueue.write { db in
            guard var unitData = try UnitData
                .filter(Column("id") == id)
                .fetchOne(db) else {
                throw AppError.dataNotFound
            }

            unitData.name = unit.name
            unitData.unitDescription = unit.description
            unitData.created = unit.created

            try unitData.update(db)
        }
    }

    func deleteUnit(id: String) async throws {
        let unitData = try await dataController.dbQueue.read { db in
            try UnitData
                .filter(Column("id") == id)
                .fetchOne(db)
        }

        try await dataController.dbQueue.write { db in
            try UnitData
                .filter(Column("id") == id)
                .deleteAll(db)
        }
    }
    
    // MARK: - Valuation Classes
    
    func fetchValuationClasses() async throws -> [ValuationClass] {
        guard let userId = authManager.currentUserId else {
            throw AppError.authenticationRequired
        }
        
        let classesData = try await dataController.dbQueue.read { db in
            try ValuationClassData
                .filter(Column("userId") == userId)
                .order(Column("name"))
                .fetchAll(db)
        }
        return classesData.map { ValuationClass(from: $0, userId: userId) }
    }
    
    func createValuationClass(_ valuationClass: ValuationClass) async throws {
        guard let userId = authManager.currentUserId else {
            throw AppError.authenticationRequired
        }
        
        // Fetch user
        guard let user = try dataController.fetchUser(byId: userId) else {
            throw AppError.dataNotFound
        }
        
        var classData = valuationClass.toData()
        classData.userId = userId
        
        try await dataController.dbQueue.write { db in
            try classData.insert(db)
        }
    }
    
    func updateValuationClass(_ valuationClass: ValuationClass) async throws {
        guard let id = valuationClass.id else {
            throw AppError.dataNotFound
        }
        
        try await dataController.dbQueue.write { db in
            guard var classData = try ValuationClassData
                .filter(Column("id") == id)
                .fetchOne(db) else {
                throw AppError.dataNotFound
            }
            
            classData.classCode = valuationClass.classCode
            classData.name = valuationClass.name
            classData.classDescription = valuationClass.description
            classData.inventoryAccountId = Int64(valuationClass.inventoryAccountId) ?? 0
            classData.cogsAccountId = Int64(valuationClass.cogsAccountId) ?? 0
            classData.isActive = valuationClass.isActive
            classData.updatedAt = Date()
            
            try classData.update(db)
        }
    }
    
    func deleteValuationClass(id: String) async throws {
        let classData = try await dataController.dbQueue.read { db in
            try ValuationClassData
                .filter(Column("id") == id)
                .fetchOne(db)
        }

        try await dataController.dbQueue.write { db in
            try ValuationClassData
                .filter(Column("id") == id)
                .deleteAll(db)
        }
    }
    
    // MARK: - Initial Inventory Journal Entry
    
    func createInitialInventoryEntry(item: InventoryItem, quantity: Int, valuationClass: ValuationClass) async throws {
        guard let userId = authManager.currentUserId else {
            throw AppError.authenticationRequired
        }
        
        let totalValue = item.purchasePrice * Double(quantity)
        
        // Fetch Owner's Equity account
        let accountService = AccountService.shared
        let accounts = try await accountService.fetchAccounts(userId: userId)
        guard let ownerEquityAccount = accounts.first(where: {
            $0.accountType.category == .equity &&
            $0.accountName.lowercased().contains("owner")
        }) else {
            throw AppError.dataNotFound
        }
        
        // Create journal entry for initial inventory
        // Debit: Inventory Account (Asset increases)
        // Credit: Owner's Equity (Equity increases)
        let lineItems = [
            JournalLineItem(
                id: UUID().uuidString,
                accountId: valuationClass.inventoryAccountId,
                accountName: "Inventory - \(valuationClass.name)",
                type: .debit,
                amount: totalValue,
                memo: "Initial inventory: \(item.displayName) (Qty: \(quantity))"
            ),
            JournalLineItem(
                id: UUID().uuidString,
                accountId: ownerEquityAccount.id ?? "",
                accountName: ownerEquityAccount.accountName,
                type: .credit,
                amount: totalValue,
                memo: "Initial inventory capital contribution"
            )
        ]
        
        let journalEntryService = JournalEntryService.shared
        let entryNumber = try await journalEntryService.generateEntryNumber()
        let journalEntry = JournalEntry(
            id: UUID().uuidString,
            entryNumber: entryNumber,
            date: Date(),
            description: "Initial inventory entry for \(item.displayName)",
            userId: userId,
            lineItems: lineItems,
            createdAt: Date()
        )
        
        try await journalEntryService.createJournalEntry(journalEntry)
    }
}

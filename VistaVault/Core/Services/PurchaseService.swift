import Foundation
import GRDB

@MainActor
class PurchaseService {
    static let shared = PurchaseService()
    
    // MARK: - Properties

    private let dataController = DataController.shared
    private let authManager = LocalAuthManager.shared

    // MARK: - Initialization

    private init() { }

    // MARK: - CRUD Operations

    func create(_ purchase: Purchase) async throws -> String {
        guard let userId = authManager.currentUserId else {
            throw AppError.authenticationRequired
        }

        try validatePurchase(purchase)

        // Fetch user
        guard let user = try dataController.fetchUser(byId: userId) else {
            throw AppError.dataNotFound
        }

        let (purchaseData, itemsData) = purchase.toDataWithItems()
        
        let purchaseId = try await dataController.dbQueue.write { db in
            var mutablePurchaseData = purchaseData
            mutablePurchaseData.userId = userId
            try mutablePurchaseData.insert(db)
            
            // Insert items
            for itemData in itemsData {
                var mutableItemData = itemData
                mutableItemData.purchaseId = purchaseData.id
                try mutableItemData.insert(db)
            }
            
            return mutablePurchaseData.id
        }
        
        return purchaseId
    }

    func read(id: String) async throws -> Purchase {
        guard let userId = authManager.currentUserId else {
            throw AppError.authenticationRequired
        }

        let (purchaseData, itemsData) = try await dataController.dbQueue.read { db in
            guard let purchase = try PurchaseData
                .filter(Column("id") == id)
                .fetchOne(db) else {
                throw AppError.notFound(message: "Purchase not found")
            }
            
            let items = try PurchaseItemData
                .filter(Column("purchaseId") == id)
                .fetchAll(db)
            
            return (purchase, items)
        }

        return Purchase(from: purchaseData, items: itemsData, userId: userId)
    }

    func update(_ purchase: Purchase) async throws {
        guard authManager.currentUserId != nil,
              let id = purchase.id
        else {
            throw AppError.invalidInput("Invalid purchase ID")
        }

        try validatePurchase(purchase)

        try await dataController.dbQueue.write { db in
            guard var purchaseData = try PurchaseData
                .filter(Column("id") == id)
                .fetchOne(db) else {
                throw AppError.dataNotFound
            }

            // Update properties
            purchaseData.purchaseNumber = purchase.purchaseNumber
            purchaseData.vendorId = purchase.vendorId
            purchaseData.vendorName = purchase.vendorName
            purchaseData.purchaseDate = purchase.purchaseDate
            purchaseData.dueDate = purchase.dueDate
            purchaseData.statusRaw = purchase.status.rawValue
            purchaseData.subtotal = purchase.subtotal
            purchaseData.taxAmount = purchase.taxAmount
            purchaseData.discountAmount = purchase.discountAmount
            purchaseData.totalAmount = purchase.totalAmount
            purchaseData.paidAmount = purchase.paidAmount
            purchaseData.notes = purchase.notes
            purchaseData.paymentMethod = purchase.paymentMethod
            purchaseData.referenceNumber = purchase.referenceNumber
            purchaseData.updatedAt = Date()

            try purchaseData.update(db)

            // Delete old items
            try PurchaseItemData
                .filter(Column("purchaseId") == id)
                .deleteAll(db)

            // Insert new items
            for item in purchase.items {
                var itemData = PurchaseItemData(
                    id: item.id,
                    itemId: item.itemId,
                    itemName: item.itemName,
                    itemDescription: item.description,
                    quantity: item.quantity,
                    unitPrice: item.unitPrice,
                    taxRate: item.taxRate,
                    discountPercent: item.discountPercent,
                    purchaseId: id
                )
                try itemData.insert(db)
            }
        }
    }

    func delete(id: String) async throws {
        guard authManager.currentUserId != nil else {
            throw AppError.authenticationRequired
        }

        try await dataController.dbQueue.write { db in
            try PurchaseData
                .filter(Column("id") == id)
                .deleteAll(db)
        }
    }

    func fetchAll() async throws -> [Purchase] {
        guard let userId = authManager.currentUserId else {
            throw AppError.authenticationRequired
        }

        let purchasesData = try await dataController.dbQueue.read { db in
            try PurchaseData
                .filter(Column("userId") == userId)
                .order(Column("purchaseDate").desc)
                .fetchAll(db)
        }
        
        return try await dataController.dbQueue.read { db in
            try purchasesData.map { purchaseData in
                let items = try PurchaseItemData
                    .filter(Column("purchaseId") == purchaseData.id)
                    .fetchAll(db)
                return Purchase(from: purchaseData, items: items, userId: userId)
            }
        }
    }

    func fetchByVendor(vendorId: String) async throws -> [Purchase] {
        guard let userId = authManager.currentUserId else {
            throw AppError.authenticationRequired
        }

        let purchasesData = try await dataController.dbQueue.read { db in
            try PurchaseData
                .filter(Column("userId") == userId && Column("vendorId") == vendorId)
                .order(Column("purchaseDate").desc)
                .fetchAll(db)
        }
        
        return try await dataController.dbQueue.read { db in
            try purchasesData.map { purchaseData in
                let items = try PurchaseItemData
                    .filter(Column("purchaseId") == purchaseData.id)
                    .fetchAll(db)
                return Purchase(from: purchaseData, items: items, userId: userId)
            }
        }
    }

    func fetchByStatus(status: Purchase.PurchaseStatus) async throws -> [Purchase] {
        guard let userId = authManager.currentUserId else {
            throw AppError.authenticationRequired
        }

        let statusRaw = status.rawValue
        let purchasesData = try await dataController.dbQueue.read { db in
            try PurchaseData
                .filter(Column("userId") == userId && Column("statusRaw") == statusRaw)
                .order(Column("purchaseDate").desc)
                .fetchAll(db)
        }
        
        return try await dataController.dbQueue.read { db in
            try purchasesData.map { purchaseData in
                let items = try PurchaseItemData
                    .filter(Column("purchaseId") == purchaseData.id)
                    .fetchAll(db)
                return Purchase(from: purchaseData, items: items, userId: userId)
            }
        }
    }

    func generatePurchaseNumber() async throws -> String {
        guard let userId = authManager.currentUserId else {
            throw AppError.authenticationRequired
        }

        let purchasesData = try await dataController.dbQueue.read { db in
            try PurchaseData
                .filter(Column("userId") == userId)
                .order(Column("createdAt").desc)
                .limit(1)
                .fetchAll(db)
        }
        let lastNumber = purchasesData.first
            .map(\.purchaseNumber)
            .flatMap { Int($0.replacingOccurrences(of: "INV-AP-", with: "")) }
            ?? 0

        return String(format: "INV-AP-%05d", lastNumber + 1)
    }

    // MARK: - Validation

    private func validatePurchase(_ purchase: Purchase) throws {
        guard !purchase.vendorId.isEmpty else {
            throw AppError.invalidInput("Vendor is required")
        }

        guard !purchase.items.isEmpty else {
            throw AppError.invalidInput("At least one item is required")
        }

        guard purchase.totalAmount >= 0 else {
            throw AppError.invalidInput("Total amount must be non-negative")
        }

        guard purchase.paidAmount >= 0, purchase.paidAmount <= purchase.totalAmount else {
            throw AppError.invalidInput("Paid amount must be between 0 and total amount")
        }
    }

    // MARK: - Business Logic

    struct PurchaseTotals {
        let subtotal: Double
        let tax: Double
        let discount: Double
        let total: Double
    }

    func calculateTotals(for items: [PurchaseItem]) -> PurchaseTotals {
        let subtotal = items.reduce(0) { $0 + $1.subtotal }
        let discount = items.reduce(0) { $0 + $1.discountAmount }
        let tax = items.reduce(0) { $0 + $1.taxAmount }
        let total = items.reduce(0) { $0 + $1.totalPrice }

        return PurchaseTotals(subtotal: subtotal, tax: tax, discount: discount, total: total)
    }

    func updatePayment(purchaseId: String, amount: Double) async throws {
        var purchase = try await read(id: purchaseId)
        purchase.paidAmount += amount

        // Update status based on payment
        if purchase.isFullyPaid {
            purchase.status = .paid
        } else if purchase.paidAmount > 0 {
            purchase.status = .partiallyPaid
        }

        try await update(purchase)
    }
}

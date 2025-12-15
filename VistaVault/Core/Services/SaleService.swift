import Foundation
import GRDB

@MainActor
class SaleService {
    static let shared = SaleService()
    
    // MARK: - Properties

    private let dataController = DataController.shared
    private let authManager = LocalAuthManager.shared

    // MARK: - Initialization

    private init() { }

    // MARK: - CRUD Operations

    func create(_ sale: Sale) async throws -> String {
        guard let userId = authManager.currentUserId else {
            throw AppError.authenticationRequired
        }

        try validateSale(sale)

        // Fetch user
        guard let _ = try dataController.fetchUser(byId: userId) else {
            throw AppError.dataNotFound
        }

        let (saleData, itemsData) = sale.toDataWithItems()
        
        let saleId = try await dataController.dbQueue.write { db in
            var mutableSaleData = saleData
            mutableSaleData.userId = userId
            try mutableSaleData.insert(db)
            
            // Insert items
            for itemData in itemsData {
                var mutableItemData = itemData
                mutableItemData.saleId = saleData.id
                try mutableItemData.insert(db)
            }
            
            return mutableSaleData.id
        }
        
        return saleId
    }

    func read(id: String) async throws -> Sale {
        guard let userId = authManager.currentUserId else {
            throw AppError.authenticationRequired
        }

        let (saleData, itemsData) = try await dataController.dbQueue.read { db in
            guard let sale = try SaleData
                .filter(Column("id") == id)
                .fetchOne(db) else {
                throw AppError.notFound(message: "Sale not found")
            }
            
            let items = try SaleItemData
                .filter(Column("saleId") == id)
                .fetchAll(db)
            
            return (sale, items)
        }

        return Sale(from: saleData, items: itemsData, userId: userId)
    }

    func update(_ sale: Sale) async throws {
        guard authManager.currentUserId != nil,
              let id = sale.id
        else {
            throw AppError.invalidInput("Invalid sale ID")
        }

        try validateSale(sale)

        try await dataController.dbQueue.write { db in
            guard var saleData = try SaleData
                .filter(Column("id") == id)
                .fetchOne(db) else {
                throw AppError.dataNotFound
            }

            // Update properties
            saleData.saleNumber = sale.saleNumber
            saleData.customerId = sale.customerId
            saleData.customerName = sale.customerName
            saleData.saleDate = sale.saleDate
            saleData.dueDate = sale.dueDate
            saleData.statusRaw = sale.status.rawValue
            saleData.subtotal = sale.subtotal
            saleData.taxAmount = sale.taxAmount
            saleData.discountAmount = sale.discountAmount
            saleData.totalAmount = sale.totalAmount
            saleData.paidAmount = sale.paidAmount
            saleData.notes = sale.notes
            saleData.paymentMethod = sale.paymentMethod
            saleData.referenceNumber = sale.referenceNumber
            saleData.updatedAt = Date()

            try saleData.update(db)

            // Delete old items
            try SaleItemData
                .filter(Column("saleId") == id)
                .deleteAll(db)

            // Insert new items
            for item in sale.items {
                var itemData = SaleItemData(
                    id: item.id,
                    itemId: item.itemId,
                    itemName: item.itemName,
                    itemDescription: item.description,
                    quantity: item.quantity,
                    unitPrice: item.unitPrice,
                    taxRate: item.taxRate,
                    discountPercent: item.discountPercent,
                    saleId: id
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
            try SaleData
                .filter(Column("id") == id)
                .deleteAll(db)
        }
    }

    func fetchAll() async throws -> [Sale] {
        guard let userId = authManager.currentUserId else {
            throw AppError.authenticationRequired
        }

        let salesData = try await dataController.dbQueue.read { db in
            try SaleData
                .filter(Column("userId") == userId)
                .order(Column("saleDate").desc)
                .fetchAll(db)
        }
        
        return try await dataController.dbQueue.read { db in
            try salesData.map { saleData in
                let items = try SaleItemData
                    .filter(Column("saleId") == saleData.id)
                    .fetchAll(db)
                return Sale(from: saleData, items: items, userId: userId)
            }
        }
    }

    func fetchByCustomer(customerId: String) async throws -> [Sale] {
        guard let userId = authManager.currentUserId else {
            throw AppError.authenticationRequired
        }

        let salesData = try await dataController.dbQueue.read { db in
            try SaleData
                .filter(Column("userId") == userId && Column("customerId") == customerId)
                .order(Column("saleDate").desc)
                .fetchAll(db)
        }
        
        return try await dataController.dbQueue.read { db in
            try salesData.map { saleData in
                let items = try SaleItemData
                    .filter(Column("saleId") == saleData.id)
                    .fetchAll(db)
                return Sale(from: saleData, items: items, userId: userId)
            }
        }
    }

    func fetchByStatus(status: Sale.SaleStatus) async throws -> [Sale] {
        guard let userId = authManager.currentUserId else {
            throw AppError.authenticationRequired
        }

        let statusRaw = status.rawValue
        let salesData = try await dataController.dbQueue.read { db in
            try SaleData
                .filter(Column("userId") == userId && Column("statusRaw") == statusRaw)
                .order(Column("saleDate").desc)
                .fetchAll(db)
        }
        
        return try await dataController.dbQueue.read { db in
            try salesData.map { saleData in
                let items = try SaleItemData
                    .filter(Column("saleId") == saleData.id)
                    .fetchAll(db)
                return Sale(from: saleData, items: items, userId: userId)
            }
        }
    }

    func generateSaleNumber() async throws -> String {
        guard let userId = authManager.currentUserId else {
            throw AppError.authenticationRequired
        }

        let salesData = try await dataController.dbQueue.read { db in
            try SaleData
                .filter(Column("userId") == userId)
                .order(Column("createdAt").desc)
                .limit(1)
                .fetchAll(db)
        }
        
        let lastNumber = salesData.first
            .map(\.saleNumber)
            .flatMap { Int($0.replacingOccurrences(of: "INV-AR-", with: "")) }
            ?? 0

        return String(format: "INV-AR-%05d", lastNumber + 1)
    }

    // MARK: - Validation

    private func validateSale(_ sale: Sale) throws {
        guard !sale.customerId.isEmpty else {
            throw AppError.invalidInput("Customer is required")
        }

        guard !sale.items.isEmpty else {
            throw AppError.invalidInput("At least one item is required")
        }

        guard sale.totalAmount >= 0 else {
            throw AppError.invalidInput("Total amount must be non-negative")
        }

        guard sale.paidAmount >= 0, sale.paidAmount <= sale.totalAmount else {
            throw AppError.invalidInput("Paid amount must be between 0 and total amount")
        }
    }

    // MARK: - Business Logic

    struct SaleTotals {
        let subtotal: Double
        let tax: Double
        let discount: Double
        let total: Double
    }

    func calculateTotals(for items: [SaleItem]) -> SaleTotals {
        let subtotal = items.reduce(0) { $0 + $1.subtotal }
        let discount = items.reduce(0) { $0 + $1.discountAmount }
        let tax = items.reduce(0) { $0 + $1.taxAmount }
        let total = items.reduce(0) { $0 + $1.totalPrice }

        return SaleTotals(subtotal: subtotal, tax: tax, discount: discount, total: total)
    }

    func updatePayment(saleId: String, amount: Double) async throws {
        var sale = try await read(id: saleId)
        sale.paidAmount += amount

        // Update status based on payment
        if sale.isFullyPaid {
            sale.status = .paid
        } else if sale.paidAmount > 0 {
            sale.status = .partiallyPaid
        }

        try await update(sale)
    }

    func updateShippingStatus(saleId: String, status: Sale.SaleStatus) async throws {
        var sale = try await read(id: saleId)

        // Validate status transition
        guard [.confirmed, .shipped].contains(status) else {
            throw AppError.invalidInput("Invalid shipping status")
        }

        sale.status = status
        try await update(sale)
    }
}

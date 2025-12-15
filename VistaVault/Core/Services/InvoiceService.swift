import Foundation
import GRDB

@MainActor
class InvoiceService {
    static let shared = InvoiceService()

    private let dataController = DataController.shared
    private let authManager = LocalAuthManager.shared

    private init() { }

    // MARK: - CRUD Operations

    func fetchInvoices() async throws -> [Invoice] {
        guard let userId = authManager.currentUserId else {
            throw AppError.authenticationRequired
        }

        let invoicesData = try await dataController.dbQueue.read { db in
            try InvoiceData
                .filter(Column("userId") == userId)
                .order(Column("invoiceDate").desc)
                .fetchAll(db)
        }
        
        return try await dataController.dbQueue.read { db in
            try invoicesData.map { invoiceData in
                let items = try InvoiceItemData
                    .filter(Column("invoiceId") == invoiceData.id)
                    .fetchAll(db)
                return Invoice(from: invoiceData, items: items, userId: userId)
            }
        }
    }

    func fetchInvoices(forCustomerId customerId: String) async throws -> [Invoice] {
        guard let userId = authManager.currentUserId else {
            throw AppError.authenticationRequired
        }

        let invoicesData = try await dataController.dbQueue.read { db in
            try InvoiceData
                .filter(Column("userId") == userId && Column("customerId") == customerId)
                .order(Column("invoiceDate").desc)
                .fetchAll(db)
        }
        
        return try await dataController.dbQueue.read { db in
            try invoicesData.map { invoiceData in
                let items = try InvoiceItemData
                    .filter(Column("invoiceId") == invoiceData.id)
                    .fetchAll(db)
                return Invoice(from: invoiceData, items: items, userId: userId)
            }
        }
    }

    func createInvoice(_ invoice: Invoice) async throws {
        guard let userId = authManager.currentUserId else {
            throw AppError.authenticationRequired
        }

        // Fetch user
        guard let _ = try dataController.fetchUser(byId: userId) else {
            throw AppError.dataNotFound
        }

        let (invoiceData, itemsData) = invoice.toDataWithItems()
        
        try await dataController.dbQueue.write { db in
            var mutableInvoiceData = invoiceData
            mutableInvoiceData.userId = userId
            try mutableInvoiceData.insert(db)
            
            // Insert items
            for itemData in itemsData {
                var mutableItemData = itemData
                mutableItemData.invoiceId = invoiceData.id
                try mutableItemData.insert(db)
            }
        }
    }

    func updateInvoice(_ invoice: Invoice) async throws {
        guard let id = invoice.id else {
            throw AppError.dataNotFound
        }

        try await dataController.dbQueue.write { db in
            guard var invoiceData = try InvoiceData
                .filter(Column("id") == id)
                .fetchOne(db) else {
                throw AppError.dataNotFound
            }

            invoiceData.invoiceNumber = invoice.invoiceNumber
            invoiceData.customerId = invoice.customerId
            invoiceData.customerName = invoice.customerName
            invoiceData.invoiceDate = invoice.invoiceDate
            invoiceData.totalAmount = invoice.totalAmount

            try invoiceData.update(db)

            // Delete old items
            try InvoiceItemData
                .filter(Column("invoiceId") == id)
                .deleteAll(db)

            // Insert new items
            for item in invoice.items {
                var itemData = InvoiceItemData(
                    id: item.id,
                    name: item.name,
                    quantity: item.quantity,
                    unitPrice: item.unitPrice,
                    invoiceId: id
                )
                try itemData.insert(db)
            }
        }
    }

    func deleteInvoice(id: String) async throws {
        let invoiceData = try await dataController.dbQueue.read { db in
            try InvoiceData
                .filter(Column("id") == id)
                .fetchOne(db)
        }

        try await dataController.dbQueue.write { db in
            try InvoiceData
                .filter(Column("id") == id)
                .deleteAll(db)
        }
    }

    func generateInvoiceNumber() async throws -> String {
        guard let userId = authManager.currentUserId else {
            throw AppError.authenticationRequired
        }

        let invoicesData = try await dataController.dbQueue.read { db in
            try InvoiceData
                .filter(Column("userId") == userId)
                .order(Column("createdAt").desc)
                .limit(1)
                .fetchAll(db)
        }
        let lastNumber = invoicesData.first
            .map(\.invoiceNumber)
            .flatMap { Int($0.replacingOccurrences(of: "INV-", with: "")) }
            ?? 0

        return String(format: "INV-%05d", lastNumber + 1)
    }
}

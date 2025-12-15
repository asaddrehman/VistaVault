import Foundation
import GRDB

@MainActor
class OutgoingPaymentService {
    static let shared = OutgoingPaymentService()
    
    private let dataController = DataController.shared
    private let authManager = LocalAuthManager.shared
    private let journalEntryService = JournalEntryService.shared
    
    private init() { }
    
    // MARK: - CRUD Operations
    
    func fetchAllOutgoingPayments() async throws -> [OutgoingPayment] {
        guard let userId = authManager.currentUserId else {
            throw AppError.authenticationRequired
        }
        
        let paymentsData = try await dataController.dbQueue.read { db in
            try OutgoingPaymentData
                .filter(Column("userId") == userId)
                .order(Column("date").desc)
                .fetchAll(db)
        }
        return paymentsData.map { OutgoingPayment(from: $0, userId: userId) }
    }
    
    func fetchOutgoingPayments(forVendorId vendorId: String) async throws -> [OutgoingPayment] {
        guard let userId = authManager.currentUserId else {
            throw AppError.authenticationRequired
        }
        
        let paymentsData = try await dataController.dbQueue.read { db in
            try OutgoingPaymentData
                .filter(Column("userId") == userId && Column("vendorId") == vendorId)
                .order(Column("date").desc)
                .fetchAll(db)
        }
        return paymentsData.map { OutgoingPayment(from: $0, userId: userId) }
    }
    
    func createOutgoingPayment(_ payment: OutgoingPayment) async throws {
        guard let userId = authManager.currentUserId else {
            throw AppError.authenticationRequired
        }
        
        // Fetch user
        guard let user = try dataController.fetchUser(byId: userId) else {
            throw AppError.dataNotFound
        }
        
        var paymentData = payment.toData()
        paymentData.userId = userId
        
        try await dataController.dbQueue.write { db in
            try paymentData.insert(db)
        }
        
        // Create journal entry for outgoing payment
        try await createJournalEntryForOutgoingPayment(payment)
    }
    
    func updateOutgoingPayment(_ payment: OutgoingPayment) async throws {
        guard let id = payment.id else {
            throw AppError.dataNotFound
        }
        
        try await dataController.dbQueue.write { db in
            guard var paymentData = try OutgoingPaymentData
                .filter(Column("id") == id)
                .fetchOne(db) else {
                throw AppError.dataNotFound
            }
            
            paymentData.paymentNumber = payment.paymentNumber
            paymentData.amount = payment.amount
            paymentData.date = payment.date
            paymentData.vendorId = payment.vendorId
            paymentData.vendorName = payment.vendorName
            paymentData.paidFromAccountId = payment.paidFromAccountId
            paymentData.notes = payment.notes
            paymentData.referenceNumber = payment.referenceNumber
            
            try paymentData.update(db)
        }
    }
    
    func deleteOutgoingPayment(id: String) async throws {
        try await dataController.dbQueue.write { db in
            try OutgoingPaymentData
                .filter(Column("id") == id)
                .deleteAll(db)
        }
    }
    
    // MARK: - Helper Methods
    
    func generatePaymentNumber() async throws -> String {
        let payments = try await fetchAllOutgoingPayments()
        let maxNumber = payments.compactMap { payment -> Int? in
            let components = payment.paymentNumber.components(separatedBy: "-")
            return components.last.flatMap { Int($0) }
        }.max() ?? 0
        
        return "OP-\(String(format: "%04d", maxNumber + 1))"
    }
    
    // MARK: - Journal Entry Creation
    
    private func createJournalEntryForOutgoingPayment(_ payment: OutgoingPayment) async throws {
        guard let userId = authManager.currentUserId else {
            throw AppError.authenticationRequired
        }
        
        // Fetch account names
        let accountService = AccountService.shared
        guard let cashAccount = try await accountService.fetchAccount(byId: payment.paidFromAccountId) else {
            throw AppError.dataNotFound
        }
        
        // Find Accounts Payable account from chart of accounts
        let accounts = try await accountService.fetchAccounts(userId: userId)
        guard let apAccount = accounts.first(where: { 
            $0.accountName.lowercased().contains("accounts payable") ||
            $0.accountName.lowercased().contains("payable")
        }) else {
            throw AppError.dataNotFound
        }
        
        // For outgoing payment to vendor:
        // Debit: Accounts Payable (Liability decreases)
        // Credit: Cash/Bank (Asset decreases)
        
        let lineItems = [
            JournalLineItem(
                id: UUID().uuidString,
                accountId: apAccount.id ?? "",
                accountName: apAccount.accountName,
                type: .debit,
                amount: payment.amount,
                memo: "Payment to \(payment.vendorName)"
            ),
            JournalLineItem(
                id: UUID().uuidString,
                accountId: payment.paidFromAccountId,
                accountName: cashAccount.accountName,
                type: .credit,
                amount: payment.amount,
                memo: "Payment made to \(payment.vendorName)"
            )
        ]
        
        let entryNumber = try await journalEntryService.generateEntryNumber()
        let journalEntry = JournalEntry(
            id: UUID().uuidString,
            entryNumber: entryNumber,
            date: payment.date,
            description: "Outgoing payment \(payment.paymentNumber) to \(payment.vendorName)",
            userId: userId,
            lineItems: lineItems,
            createdAt: Date()
        )
        
        try await journalEntryService.createJournalEntry(journalEntry)
    }
}

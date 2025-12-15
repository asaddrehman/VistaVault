import Foundation
import GRDB

@MainActor
class IncomingPaymentService {
    static let shared = IncomingPaymentService()
    
    private let dataController = DataController.shared
    private let authManager = LocalAuthManager.shared
    private let journalEntryService = JournalEntryService.shared
    
    private init() { }
    
    // MARK: - CRUD Operations
    
    func fetchAllIncomingPayments() async throws -> [IncomingPayment] {
        guard let userId = authManager.currentUserId else {
            throw AppError.authenticationRequired
        }
        
        let paymentsData = try await dataController.dbQueue.read { db in
            try IncomingPaymentData
                .filter(Column("userId") == userId)
                .order(Column("date").desc)
                .fetchAll(db)
        }
        return paymentsData.map { IncomingPayment(from: $0, userId: userId) }
    }
    
    func fetchIncomingPayments(forCustomerId customerId: String) async throws -> [IncomingPayment] {
        guard let userId = authManager.currentUserId else {
            throw AppError.authenticationRequired
        }
        
        let paymentsData = try await dataController.dbQueue.read { db in
            try IncomingPaymentData
                .filter(Column("userId") == userId && Column("customerId") == customerId)
                .order(Column("date").desc)
                .fetchAll(db)
        }
        return paymentsData.map { IncomingPayment(from: $0, userId: userId) }
    }
    
    func createIncomingPayment(_ payment: IncomingPayment) async throws {
        guard let userId = authManager.currentUserId else {
            throw AppError.authenticationRequired
        }
        
        // Fetch user
        guard let _ = try dataController.fetchUser(byId: userId) else {
            throw AppError.dataNotFound
        }
        
        var paymentData = payment.toData()
        paymentData.userId = userId
        
        try await dataController.dbQueue.write { db in
            try paymentData.insert(db)
        }
        
        // Create journal entry for incoming payment
        try await createJournalEntryForIncomingPayment(payment)
    }
    
    func updateIncomingPayment(_ payment: IncomingPayment) async throws {
        guard let id = payment.id else {
            throw AppError.dataNotFound
        }
        
        try await dataController.dbQueue.write { db in
            guard var paymentData = try IncomingPaymentData
                .filter(Column("id") == id)
                .fetchOne(db) else {
                throw AppError.dataNotFound
            }
            
            paymentData.paymentNumber = payment.paymentNumber
            paymentData.amount = payment.amount
            paymentData.date = payment.date
            paymentData.customerId = payment.customerId
            paymentData.customerName = payment.customerName
            paymentData.receivedInAccountId = payment.receivedInAccountId
            paymentData.notes = payment.notes
            paymentData.referenceNumber = payment.referenceNumber
            
            try paymentData.update(db)
        }
    }
    
    func deleteIncomingPayment(id: String) async throws {
        try await dataController.dbQueue.write { db in
            try IncomingPaymentData
                .filter(Column("id") == id)
                .deleteAll(db)
        }
    }
    
    // MARK: - Helper Methods
    
    func generatePaymentNumber() async throws -> String {
        let payments = try await fetchAllIncomingPayments()
        let maxNumber = payments.compactMap { payment -> Int? in
            let components = payment.paymentNumber.components(separatedBy: "-")
            return components.last.flatMap { Int($0) }
        }.max() ?? 0
        
        return "IP-\(String(format: "%04d", maxNumber + 1))"
    }
    
    // MARK: - Journal Entry Creation
    
    private func createJournalEntryForIncomingPayment(_ payment: IncomingPayment) async throws {
        guard let userId = authManager.currentUserId else {
            throw AppError.authenticationRequired
        }
        
        // Fetch account names
        let accountService = AccountService.shared
        guard let cashAccount = try await accountService.fetchAccount(byId: payment.receivedInAccountId) else {
            throw AppError.dataNotFound
        }
        
        // Find Accounts Receivable account from chart of accounts
        let accounts = try await accountService.fetchAccounts(userId: userId)
        guard let arAccount = accounts.first(where: { 
            $0.accountName.lowercased().contains("accounts receivable") ||
            $0.accountName.lowercased().contains("receivable")
        }) else {
            throw AppError.dataNotFound
        }
        
        // For incoming payment from customer:
        // Debit: Cash/Bank (Asset increases)
        // Credit: Accounts Receivable (Asset decreases)
        
        let lineItems = [
            JournalLineItem(
                id: UUID().uuidString,
                accountId: payment.receivedInAccountId,
                accountName: cashAccount.accountName,
                type: .debit,
                amount: payment.amount,
                memo: "Payment received from \(payment.customerName)"
            ),
            JournalLineItem(
                id: UUID().uuidString,
                accountId: arAccount.id ?? "",
                accountName: arAccount.accountName,
                type: .credit,
                amount: payment.amount,
                memo: "Payment from \(payment.customerName)"
            )
        ]
        
        let entryNumber = try await journalEntryService.generateEntryNumber()
        let journalEntry = JournalEntry(
            id: UUID().uuidString,
            entryNumber: entryNumber,
            date: payment.date,
            description: "Incoming payment \(payment.paymentNumber) from \(payment.customerName)",
            userId: userId,
            lineItems: lineItems,
            createdAt: Date()
        )
        
        try await journalEntryService.createJournalEntry(journalEntry)
    }
}

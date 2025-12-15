import Foundation
import GRDB

@MainActor
class JournalEntryService {
    static let shared = JournalEntryService()
    
    private let dataController = DataController.shared
    private let authManager = LocalAuthManager.shared
    
    private init() { }
    
    // MARK: - CRUD Operations
    
    func fetchAllJournalEntries() async throws -> [JournalEntry] {
        guard let userId = authManager.currentUserId else {
            throw AppError.authenticationRequired
        }
        
        let entriesData = try await dataController.dbQueue.read { db in
            try JournalEntryData
                .filter(Column("userId") == userId)
                .order(Column("date").desc)
                .fetchAll(db)
        }
        
        return try await dataController.dbQueue.read { db in
            try entriesData.map { entryData in
                let lineItems = try JournalLineItemData
                    .filter(Column("journalEntryId") == entryData.id)
                    .fetchAll(db)
                return JournalEntry(from: entryData, items: lineItems, userId: userId)
            }
        }
    }
    
    func fetchJournalEntry(byId id: String) async throws -> JournalEntry? {
        guard let userId = authManager.currentUserId else {
            throw AppError.authenticationRequired
        }
        
        let (entryData, lineItems): (JournalEntryData?, [JournalLineItemData]) = try await dataController.dbQueue.read { db in
            guard let entry = try JournalEntryData
                .filter(Column("id") == id)
                .fetchOne(db) else {
                return (nil, [JournalLineItemData]())
            }
            
            let items = try JournalLineItemData
                .filter(Column("journalEntryId") == id)
                .fetchAll(db)
            
            return (entry, items)
        }

        guard let entryData = entryData else {
            return nil
        }
        
        return JournalEntry(from: entryData, items: lineItems, userId: userId)
    }
    
    func createJournalEntry(_ entry: JournalEntry) async throws {
        guard let userId = authManager.currentUserId else {
            throw AppError.authenticationRequired
        }
        
        // Validate that entry is balanced
        guard entry.isBalanced else {
            throw AppError.validationFailed("Journal entry must be balanced (debits = credits)")
        }
        
        // Fetch user
        guard let _ = try dataController.fetchUser(byId: userId) else {
            throw AppError.dataNotFound
        }
        
        let (entryData, lineItemsData) = entry.toDataWithLineItems()
        
        try await dataController.dbQueue.write { db in
            var mutableEntryData = entryData
            mutableEntryData.userId = userId
            try mutableEntryData.insert(db)
            
            // Add line items with relationship
            for lineItemData in lineItemsData {
                var mutableLineItemData = lineItemData
                mutableLineItemData.journalEntryId = entryData.id
                try mutableLineItemData.insert(db)
            }
        }
    }
    
    func updateJournalEntry(_ entry: JournalEntry) async throws {
        guard let id = entry.id else {
            throw AppError.dataNotFound
        }
        
        // Validate that entry is balanced
        guard entry.isBalanced else {
            throw AppError.validationFailed("Journal entry must be balanced (debits = credits)")
        }
        
        try await dataController.dbQueue.write { db in
            guard var entryData = try JournalEntryData
                .filter(Column("id") == id)
                .fetchOne(db) else {
                throw AppError.dataNotFound
            }
            
            entryData.entryNumber = entry.entryNumber
            entryData.date = entry.date
            entryData.entryDescription = entry.description
            
            try entryData.update(db)
            
            // Delete old line items
            try JournalLineItemData
                .filter(Column("journalEntryId") == id)
                .deleteAll(db)
            
            // Insert new line items
            for lineItem in entry.lineItems {
                var lineItemData = JournalLineItemData(
                    id: lineItem.id,
                    accountId: lineItem.accountId,
                    accountName: lineItem.accountName,
                    typeRaw: lineItem.type.rawValue,
                    amount: lineItem.amount,
                    memo: lineItem.memo,
                    journalEntryId: id
                )
                try lineItemData.insert(db)
            }
        }
    }
    
    func deleteJournalEntry(id: String) async throws {
        let entryData = try await dataController.dbQueue.read { db in
            try JournalEntryData
                .filter(Column("id") == id)
                .fetchOne(db)
        }

        try await dataController.dbQueue.write { db in
            try JournalEntryData
                .filter(Column("id") == id)
                .deleteAll(db)
        }
    }
    
    // MARK: - Helper Methods
    
    func generateEntryNumber() async throws -> String {
        let entries = try await fetchAllJournalEntries()
        let maxNumber = entries.compactMap { entry -> Int? in
            let components = entry.entryNumber.components(separatedBy: "-")
            return components.last.flatMap { Int($0) }
        }.max() ?? 0
        
        return "JE-\(String(format: "%04d", maxNumber + 1))"
    }
}

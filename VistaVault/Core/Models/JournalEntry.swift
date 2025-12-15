import Foundation

struct JournalEntry: Identifiable, Codable {
    var id: String?
    let entryNumber: String
    let date: Date
    let description: String
    let userId: String
    let lineItems: [JournalLineItem]
    var createdAt: Date?

    var isBalanced: Bool {
        let totalDebits = lineItems.filter { $0.type == .debit }.reduce(0) { $0 + $1.amount }
        let totalCredits = lineItems.filter { $0.type == .credit }.reduce(0) { $0 + $1.amount }
        return abs(totalDebits - totalCredits) < AppConstants.Accounting.floatingPointTolerance
    }

    enum CodingKeys: String, CodingKey {
        case id
        case entryNumber = "entry_number"
        case date
        case description
        case userId = "user_id"
        case lineItems = "line_items"
        case createdAt = "created_at"
    }
}

struct JournalLineItem: Identifiable, Codable {
    let id: String
    let accountId: String
    let accountName: String
    let type: EntryType
    let amount: Double
    let memo: String?

    enum EntryType: String, Codable {
        case debit = "Debit"
        case credit = "Credit"
    }

    enum CodingKeys: String, CodingKey {
        case id
        case accountId = "account_id"
        case accountName = "account_name"
        case type
        case amount
        case memo
    }
}

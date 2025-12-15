import Foundation

struct OutgoingPayment: Codable, Identifiable, Hashable {
    var id: String?
    var paymentNumber: String
    var amount: Double
    var date: Date
    var vendorId: String
    var vendorName: String
    var paidFromAccountId: String // The account from which money is paid (e.g., Cash, Bank)
    var userId: String
    var notes: String?
    var referenceNumber: String?
    var createdAt: Date?
    
    init(
        id: String? = nil,
        paymentNumber: String = UUID().uuidString,
        amount: Double,
        date: Date,
        vendorId: String,
        vendorName: String,
        paidFromAccountId: String,
        userId: String,
        notes: String? = nil,
        referenceNumber: String? = nil,
        createdAt: Date? = nil
    ) {
        self.id = id
        self.paymentNumber = paymentNumber
        self.amount = amount
        self.date = date
        self.vendorId = vendorId
        self.vendorName = vendorName
        self.paidFromAccountId = paidFromAccountId
        self.userId = userId
        self.notes = notes
        self.referenceNumber = referenceNumber
        self.createdAt = createdAt
    }
}

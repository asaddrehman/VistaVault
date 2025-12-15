import Foundation

struct IncomingPayment: Codable, Identifiable, Hashable {
    var id: String?
    var paymentNumber: String
    var amount: Double
    var date: Date
    var customerId: String
    var customerName: String
    var receivedInAccountId: String // The account where money is received (e.g., Cash, Bank)
    var userId: String
    var notes: String?
    var referenceNumber: String?
    var createdAt: Date?
    
    init(
        id: String? = nil,
        paymentNumber: String = UUID().uuidString,
        amount: Double,
        date: Date,
        customerId: String,
        customerName: String,
        receivedInAccountId: String,
        userId: String,
        notes: String? = nil,
        referenceNumber: String? = nil,
        createdAt: Date? = nil
    ) {
        self.id = id
        self.paymentNumber = paymentNumber
        self.amount = amount
        self.date = date
        self.customerId = customerId
        self.customerName = customerName
        self.receivedInAccountId = receivedInAccountId
        self.userId = userId
        self.notes = notes
        self.referenceNumber = referenceNumber
        self.createdAt = createdAt
    }
}

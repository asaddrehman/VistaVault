import Foundation

// MARK: - Payment Transaction Type

enum PaymentTransactionType: String, Codable {
    case credit = "Credit"
    case debit = "Debit"
}

// MARK: - Unified Payment Protocol

protocol PaymentProtocol {
    var id: String? { get }
    var paymentNumber: String { get }
    var amount: Double { get }
    var date: Date { get }
    var customerId: String { get }
    var customerName: String { get }
    var notes: String? { get }
    var referenceNumber: String? { get }
    var transactionType: PaymentTransactionType { get }
    var transactionNumber: String { get }
}

// MARK: - Payment Wrapper

struct Payment: Identifiable, Hashable, Codable {
    var id: String?
    var paymentNumber: String
    var amount: Double
    var date: Date
    var customerId: String
    var customerName: String
    var transactionType: PaymentTransactionType
    var notes: String?
    var referenceNumber: String?
    var createdAt: Date?
    var userId: String
    
    var transactionNumber: String {
        paymentNumber
    }
    
    // Convenience initializer from IncomingPayment
    init(from incoming: IncomingPayment) {
        self.id = incoming.id
        self.paymentNumber = incoming.paymentNumber
        self.amount = incoming.amount
        self.date = incoming.date
        self.customerId = incoming.customerId
        self.customerName = incoming.customerName
        self.transactionType = .credit
        self.notes = incoming.notes
        self.referenceNumber = incoming.referenceNumber
        self.createdAt = incoming.createdAt
        self.userId = incoming.userId
    }
    
    // Convenience initializer from OutgoingPayment
    init(from outgoing: OutgoingPayment) {
        self.id = outgoing.id
        self.paymentNumber = outgoing.paymentNumber
        self.amount = outgoing.amount
        self.date = outgoing.date
        self.customerId = outgoing.vendorId
        self.customerName = outgoing.vendorName
        self.transactionType = .debit
        self.notes = outgoing.notes
        self.referenceNumber = outgoing.referenceNumber
        self.createdAt = outgoing.createdAt
        self.userId = outgoing.userId
    }
    
    static func == (lhs: Payment, rhs: Payment) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Extensions for IncomingPayment

extension IncomingPayment: PaymentProtocol {
    var transactionType: PaymentTransactionType { .credit }
    var transactionNumber: String { paymentNumber }
}

// MARK: - Extensions for OutgoingPayment

extension OutgoingPayment: PaymentProtocol {
    var customerId: String { vendorId }
    var customerName: String { vendorName }
    var transactionType: PaymentTransactionType { .debit }
    var transactionNumber: String { paymentNumber }
}

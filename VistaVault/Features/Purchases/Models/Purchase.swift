import Foundation

struct Purchase: Identifiable, Codable {
    var id: String?
    var userId: String
    var purchaseNumber: String
    var vendorId: String
    var vendorName: String
    var purchaseDate: Date
    var dueDate: Date?
    var status: PurchaseStatus
    var items: [PurchaseItem]
    var subtotal: Double
    var taxAmount: Double
    var discountAmount: Double
    var totalAmount: Double
    var paidAmount: Double
    var notes: String?
    var paymentMethod: String?
    var referenceNumber: String?

    var createdAt: Date?
    var updatedAt: Date?

    enum PurchaseStatus: String, Codable, CaseIterable {
        case draft = "Draft"
        case ordered = "Ordered"
        case received = "Received"
        case partiallyPaid = "Partially Paid"
        case paid = "Paid"
        case cancelled = "Cancelled"

        var icon: String {
            switch self {
            case .draft: "doc.text"
            case .ordered: "arrow.right.circle"
            case .received: "checkmark.circle"
            case .partiallyPaid: "dollarsign.circle.fill"
            case .paid: "checkmark.seal.fill"
            case .cancelled: "xmark.circle"
            }
        }

        var color: String {
            switch self {
            case .draft: "gray"
            case .ordered: "blue"
            case .received: "green"
            case .partiallyPaid: "orange"
            case .paid: "green"
            case .cancelled: "red"
            }
        }
    }

    // MARK: - Computed Properties

    var balanceAmount: Double {
        totalAmount - paidAmount
    }

    var isFullyPaid: Bool {
        abs(balanceAmount) < 0.01
    }

    // MARK: - CodingKeys

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case purchaseNumber = "purchase_number"
        case vendorId = "vendor_id"
        case vendorName = "vendor_name"
        case purchaseDate = "purchase_date"
        case dueDate = "due_date"
        case status
        case items
        case subtotal
        case taxAmount = "tax_amount"
        case discountAmount = "discount_amount"
        case totalAmount = "total_amount"
        case paidAmount = "paid_amount"
        case notes
        case paymentMethod = "payment_method"
        case referenceNumber = "reference_number"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct PurchaseItem: Identifiable, Codable {
    let id: String
    var itemId: String
    var itemName: String
    var description: String?
    var quantity: Double
    var unitPrice: Double
    var taxRate: Double
    var discountPercent: Double

    var subtotal: Double {
        quantity * unitPrice
    }

    var discountAmount: Double {
        subtotal * (discountPercent / 100)
    }

    var taxAmount: Double {
        (subtotal - discountAmount) * (taxRate / 100)
    }

    var totalPrice: Double {
        subtotal - discountAmount + taxAmount
    }

    enum CodingKeys: String, CodingKey {
        case id
        case itemId = "item_id"
        case itemName = "item_name"
        case description
        case quantity
        case unitPrice = "unit_price"
        case taxRate = "tax_rate"
        case discountPercent = "discount_percent"
    }
}

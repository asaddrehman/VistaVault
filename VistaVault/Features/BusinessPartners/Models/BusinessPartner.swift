import Foundation

struct BusinessPartner: Codable, Identifiable, Hashable {
    var id: String?
    var userId: String
    var partnerCode: String
    var name: String
    var type: PartnerType
    var balance: Double
    var lastTransactionDate: Date
    var accountId: String // Linked ledger account

    // Contact Information
    var firstName: String?
    var lastName: String?
    var email: String?
    var phone: String?
    var mobile: String?
    var website: String?

    // Address Information
    var address: String?
    var city: String?
    var state: String?
    var postalCode: String?
    var country: String?

    // Tax Information
    var taxId: String?
    var vatNumber: String?

    // Financial Terms
    var creditLimit: Double?
    var paymentTerms: Int? // Days
    var discount: Double? // Percentage

    // Status
    var isActive: Bool
    var notes: String?

    var createdAt: Date?
    var updatedAt: Date?

    enum PartnerType: String, Codable, CaseIterable {
        case customer = "Customer"
        case vendor = "Vendor"
        case both = "Both"

        var icon: String {
            switch self {
            case .customer: "person.fill"
            case .vendor: "building.2.fill"
            case .both: "person.2.fill"
            }
        }
    }

    // MARK: - Computed Properties

    var fullName: String {
        [firstName, lastName].compactMap { $0 }.joined(separator: " ")
    }

    var displayName: String {
        name.isEmpty ? fullName : name
    }

    var formattedAddress: String? {
        let components = [address, city, state, postalCode, country].compactMap { $0 }
        return components.isEmpty ? nil : components.joined(separator: ", ")
    }

    var isCustomer: Bool {
        type == .customer || type == .both
    }

    var isVendor: Bool {
        type == .vendor || type == .both
    }

    // MARK: - Hashable

    static func == (lhs: BusinessPartner, rhs: BusinessPartner) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    // MARK: - CodingKeys

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case partnerCode = "partner_code"
        case name
        case type
        case balance
        case lastTransactionDate = "last_transaction_date"
        case accountId = "account_id"
        case firstName = "first_name"
        case lastName = "last_name"
        case email
        case phone
        case mobile
        case website
        case address
        case city
        case state
        case postalCode = "postal_code"
        case country
        case taxId = "tax_id"
        case vatNumber = "vat_number"
        case creditLimit = "credit_limit"
        case paymentTerms = "payment_terms"
        case discount
        case isActive = "is_active"
        case notes
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Type Aliases for backwards compatibility

typealias Customer = BusinessPartner

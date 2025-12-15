import Foundation
import GRDB

@MainActor
class BusinessPartnerService {
    static let shared = BusinessPartnerService()
    private let dataController = DataController.shared

    private init() { }

    // MARK: - CRUD Operations

    func fetchPartners(userId: String) async throws -> [BusinessPartner] {
        let partnersData = try await dataController.dbQueue.read { db in
            try BusinessPartnerData
                .filter(Column("userId") == userId)
                .order(Column("name"))
                .fetchAll(db)
        }
        return partnersData.map { BusinessPartner(from: $0, userId: userId) }
    }

    func createPartner(_ partner: BusinessPartner) async throws {
        guard !partner.userId.isEmpty else {
            throw AppError.requiredFieldMissing("User ID")
        }

        // Fetch user
        guard let _ = try dataController.fetchUser(byId: partner.userId) else {
            throw AppError.dataNotFound
        }

        var partnerData = partner.toData()
        partnerData.userId = partner.userId

        try await dataController.dbQueue.write { db in
            try partnerData.insert(db)
        }
    }

    func updatePartner(_ partner: BusinessPartner) async throws {
        guard let id = partner.id else {
            throw AppError.dataNotFound
        }

        try await dataController.dbQueue.write { db in
            guard var partnerData = try BusinessPartnerData
                .filter(Column("id") == id)
                .fetchOne(db) else {
                throw AppError.dataNotFound
            }

            // Update properties
            partnerData.partnerCode = partner.partnerCode
            partnerData.name = partner.name
            partnerData.typeRaw = partner.type.rawValue
            partnerData.balance = partner.balance
            partnerData.lastTransactionDate = partner.lastTransactionDate
            partnerData.accountId = partner.accountId
            partnerData.firstName = partner.firstName
            partnerData.lastName = partner.lastName
            partnerData.email = partner.email
            partnerData.phone = partner.phone
            partnerData.mobile = partner.mobile
            partnerData.website = partner.website
            partnerData.address = partner.address
            partnerData.city = partner.city
            partnerData.state = partner.state
            partnerData.postalCode = partner.postalCode
            partnerData.country = partner.country
            partnerData.taxId = partner.taxId
            partnerData.vatNumber = partner.vatNumber
            partnerData.creditLimit = partner.creditLimit
            partnerData.paymentTerms = partner.paymentTerms
            partnerData.discount = partner.discount
            partnerData.isActive = partner.isActive
            partnerData.notes = partner.notes
            partnerData.updatedAt = Date()

            try partnerData.update(db)
        }
    }

    func deletePartner(id: String) async throws {
        try await dataController.dbQueue.write { db in
            try BusinessPartnerData
                .filter(Column("id") == id)
                .deleteAll(db)
        }
    }

    // MARK: - Business Logic

    func generatePartnerCode(type: BusinessPartner.PartnerType, existingPartners: [BusinessPartner]) -> String {
        let prefix = switch type {
        case .customer: "CUS"
        case .vendor: "VEN"
        case .both: "BP"
        }

        let existingCodes = existingPartners
            .filter { $0.type == type }
            .compactMap { Int($0.partnerCode.replacingOccurrences(of: prefix, with: "")) }

        let nextNumber = (existingCodes.max() ?? 0) + 1
        return String(format: "%@%04d", prefix, nextNumber)
    }

    func filterPartners(_ partners: [BusinessPartner], by type: BusinessPartner.PartnerType?) -> [BusinessPartner] {
        guard let type else { return partners }

        return partners.filter { partner in
            switch type {
            case .customer: partner.isCustomer
            case .vendor: partner.isVendor
            case .both: partner.type == .both
            }
        }
    }

    func searchPartners(_ partners: [BusinessPartner], searchText: String) -> [BusinessPartner] {
        guard !searchText.isEmpty else { return partners }

        return partners.filter { partner in
            partner.displayName.localizedCaseInsensitiveContains(searchText) ||
                partner.email?.localizedCaseInsensitiveContains(searchText) == true ||
                partner.partnerCode.localizedCaseInsensitiveContains(searchText)
        }
    }

    func validatePartner(_ partner: BusinessPartner) -> Result<Void, AppError> {
        // Name validation
        guard !partner.name.trimmingCharacters(in: .whitespaces).isEmpty else {
            return .failure(.requiredFieldMissing("Partner name"))
        }

        // Email validation (if provided)
        if let email = partner.email, !email.isEmpty {
            let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
            let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
            guard emailPredicate.evaluate(with: email) else {
                return .failure(.validationFailed("Invalid email format"))
            }
        }

        // Credit limit validation
        if let creditLimit = partner.creditLimit {
            guard creditLimit >= 0 else {
                return .failure(.validationFailed("Credit limit must be non-negative"))
            }
        }

        return .success(())
    }
}

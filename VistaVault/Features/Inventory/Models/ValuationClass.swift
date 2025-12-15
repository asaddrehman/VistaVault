import Foundation

struct ValuationClass: Identifiable, Codable, Hashable {
    var id: String?
    var userId: String
    var classCode: String
    var name: String
    var description: String?
    var inventoryAccountId: String // GL Account for Inventory Asset
    var cogsAccountId: String // GL Account for Cost of Goods Sold
    var isActive: Bool
    var createdAt: Date?
    var updatedAt: Date?
    
    init(
        id: String? = nil,
        userId: String,
        classCode: String,
        name: String,
        description: String? = nil,
        inventoryAccountId: String,
        cogsAccountId: String,
        isActive: Bool = true,
        createdAt: Date? = nil,
        updatedAt: Date? = nil
    ) {
        self.id = id
        self.userId = userId
        self.classCode = classCode
        self.name = name
        self.description = description
        self.inventoryAccountId = inventoryAccountId
        self.cogsAccountId = cogsAccountId
        self.isActive = isActive
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    // MARK: - CodingKeys
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case classCode = "class_code"
        case name
        case description
        case inventoryAccountId = "inventory_account_id"
        case cogsAccountId = "cogs_account_id"
        case isActive = "is_active"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

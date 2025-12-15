//
//  InventoryItem.swift
//  ValueVault
//
//  Created by Asad ur Rehman on 26/10/1446 AH.
//
import Foundation

struct InventoryItem: Identifiable, Codable, Hashable {
    // MARK: - ID

    var id: String?

    // MARK: - Core Properties

    var productCode: String
    var name: String
    var description: String
    var displayName: String
    var unitId: String // Reference to Units collection
    var valuationClassId: String? // Reference to ValuationClass
    var salesPrice: Double
    var purchasePrice: Double
    var availableQuantity: Int
    var timestamp: Date

    // MARK: - Coding Keys

    enum CodingKeys: String, CodingKey {
        case id
        case productCode = "product_code"
        case name
        case description
        case displayName = "display_name"
        case unitId = "unit_id"
        case valuationClassId = "valuation_class_id"
        case salesPrice = "sales_price"
        case purchasePrice = "purchase_price"
        case availableQuantity = "available_quantity"
        case timestamp
    }

    // MARK: - Initializer

    init(
        id: String? = nil,
        productCode: String,
        name: String,
        description: String,
        displayName: String,
        unitId: String,
        valuationClassId: String? = nil,
        salesPrice: Double,
        purchasePrice: Double,
        availableQuantity: Int,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.productCode = productCode
        self.name = name
        self.description = description
        self.displayName = displayName
        self.unitId = unitId
        self.valuationClassId = valuationClassId
        self.salesPrice = salesPrice
        self.purchasePrice = purchasePrice
        self.availableQuantity = availableQuantity
        self.timestamp = timestamp
    }
}

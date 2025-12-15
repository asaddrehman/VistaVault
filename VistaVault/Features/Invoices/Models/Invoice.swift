//
//  Invoice.swift
//  ValueVault
//
//  Created by Asad ur Rehman on 04/11/1446 AH.
//  Copyright © 1446 AH CodeCraft. All rights reserved.
//
import Foundation
import SwiftUI

struct Invoice: Identifiable, Codable, Hashable {
    var id: String?
    let invoiceNumber: String
    let customerId: String
    let customerName: String
    let invoiceDate: Date
    let items: [InvoiceItem]
    let totalAmount: Double
    let userId: String
    var createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case invoiceNumber = "invoice_number"
        case customerId = "customer_id"
        case customerName = "customer_name"
        case invoiceDate = "invoice_date"
        case items
        case totalAmount = "total_amount"
        case userId = "user_id"
        case createdAt = "created_at"
    }

    init(
        invoiceNumber: String,
        customerId: String,
        customerName: String,
        invoiceDate: Date,
        items: [InvoiceItem],
        totalAmount: Double,
        userId: String
    ) {
        self.invoiceNumber = invoiceNumber
        self.customerId = customerId
        self.customerName = customerName
        self.invoiceDate = invoiceDate
        self.items = items
        self.totalAmount = totalAmount
        self.userId = userId
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        invoiceNumber = try container.decode(String.self, forKey: .invoiceNumber)
        customerId = try container.decode(String.self, forKey: .customerId)
        customerName = try container.decode(String.self, forKey: .customerName)
        invoiceDate = try container.decode(Date.self, forKey: .invoiceDate)
        items = try container.decode([InvoiceItem].self, forKey: .items)
        totalAmount = try container.decode(Double.self, forKey: .totalAmount)
        userId = try container.decode(String.self, forKey: .userId)
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
    }
}

struct InvoiceItem: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    var quantity: Int // Changed to var
    var unitPrice: Double // Changed to var
    var totalPrice: Double { Double(quantity) * unitPrice }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case quantity
        case unitPrice = "unit_price"
    }

    init(id: String, name: String, quantity: Int, unitPrice: Double) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.unitPrice = unitPrice
    }
}

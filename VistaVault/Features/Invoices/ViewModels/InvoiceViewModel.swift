//
//  InvoiceViewModel.swift
//  ValueVault
//
//  Created by Asad ur Rehman on 04/11/1446 AH.
//  Copyright © 1446 AH CodeCraft. All rights reserved.
//
import Foundation

@MainActor
class InvoiceViewModel: ObservableObject {
    @Published var selectedCustomer: Customer?
    @Published var invoiceItems: [InvoiceItem] = []
    @Published var totalAmount: Double = 0
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var invoices: [Invoice] = []

    private let invoiceService = InvoiceService.shared
    private let inventoryService = InventoryService.shared
    private let authManager = LocalAuthManager.shared

    func addItem(inventoryItem: InventoryItem, quantity: Int, price: Double) {
        let newItem = InvoiceItem(
            id: inventoryItem.id ?? "",
            name: inventoryItem.displayName,
            quantity: quantity,
            unitPrice: price
        )

        invoiceItems.append(newItem)
        calculateTotal()
    }

    func removeItem(at index: Int) {
        invoiceItems.remove(at: index)
        calculateTotal()
    }

    func updatePrice(for itemId: String, newPrice: Double) {
        if let index = invoiceItems.firstIndex(where: { $0.id == itemId }) {
            var updatedItem = invoiceItems[index]
            updatedItem.unitPrice = newPrice
            invoiceItems[index] = updatedItem
            calculateTotal()
        }
    }

    func updateQuantity(for itemId: String, newQuantity: Int) {
        if let index = invoiceItems.firstIndex(where: { $0.id == itemId }) {
            var updatedItem = invoiceItems[index]
            updatedItem.quantity = newQuantity
            invoiceItems[index] = updatedItem
            calculateTotal()
        }
    }

    private func calculateTotal() {
        totalAmount = invoiceItems.reduce(0) { $0 + $1.totalPrice }
    }

    func fetchInvoices() {
        Task {
            do {
                invoices = try await invoiceService.fetchInvoices()
            } catch {
                errorMessage = "Fetch error: \(error.localizedDescription)"
            }
        }
    }

    deinit { }

    func createInvoice() async -> Result<String, Error> {
        guard authManager.currentUserId != nil else {
            return .failure(NSError(
                domain: "Auth",
                code: 401,
                userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]
            ))
        }

        guard let customer = selectedCustomer,
              let customerId = customer.id,
              !customer.displayName.isEmpty
        else {
            return .failure(NSError(
                domain: "Invoice",
                code: 400,
                userInfo: [NSLocalizedDescriptionKey: "Invalid customer selection"]
            ))
        }

        // 1. Create invoice
        let invoice = Invoice(
            invoiceNumber: generateInvoiceNumber(),
            customerId: customerId,
            customerName: customer.displayName,
            invoiceDate: Date(),
            items: invoiceItems,
            totalAmount: totalAmount,
            userId: authManager.currentUserId ?? ""
        )

        do {
            // 2. Check and update inventory items
            try await updateInventoryItems()

            // 3. Create invoice
            try await invoiceService.createInvoice(invoice)
            return .success(invoice.invoiceNumber)
        } catch {
            return .failure(error)
        }
    }

    private func updateInventoryItems() async throws {
        let inventoryItems = try await inventoryService.fetchInventoryItems()

        for item in invoiceItems {
            guard let inventoryItem = inventoryItems.first(where: { $0.id == item.id }) else {
                throw NSError(
                    domain: "Inventory",
                    code: 404,
                    userInfo: [NSLocalizedDescriptionKey: "Item \(item.name) not found"]
                )
            }

            let newQuantity = inventoryItem.availableQuantity - item.quantity
            guard newQuantity >= 0 else {
                throw NSError(
                    domain: "Inventory",
                    code: 409,
                    userInfo: [NSLocalizedDescriptionKey: "Insufficient stock for \(item.name)"]
                )
            }

            var updatedItem = inventoryItem
            updatedItem.availableQuantity = newQuantity
            try await inventoryService.updateInventoryItem(updatedItem)
        }
    }

    private func generateInvoiceNumber() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let dateString = dateFormatter.string(from: Date())
        let random = String(Int.random(in: 1000 ... 9999))
        return "INV-\(dateString)-\(random)"
    }
}

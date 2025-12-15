import SwiftUI

struct InvoiceCreationView: View {
    @ObservedObject var vm: InvoiceViewModel
    @ObservedObject var businessPartnerVM: BusinessPartnerViewModel
    @ObservedObject var inventoryVM: InventoryViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showCustomerPicker = false
    @State private var showInventoryPicker = false
    @State private var errorMessage = ""
    @State private var showError = false

    var body: some View {
        NavigationStack {
            Form {
                // Customer Section
                Section(header: Text("Customer")) {
                    if let customer = vm.selectedCustomer {
                        CustomerSummaryView(customer: customer) {
                            vm.selectedCustomer = nil
                        }
                    } else {
                        Button("Select Customer") {
                            showCustomerPicker = true
                        }
                    }
                }

                // Items Section
                Section(header: Text("Items")) {
                    ForEach(vm.invoiceItems) { item in
                        InvoiceItemRow(item: item) { newPrice in
                            vm.updatePrice(for: item.id, newPrice: newPrice)
                        } onQuantityChange: { newQuantity in
                            vm.updateQuantity(for: item.id, newQuantity: newQuantity)
                        }
                    }
                    .onDelete { indices in
                        indices.forEach { vm.removeItem(at: $0) }
                    }

                    Button("Add Item") {
                        showInventoryPicker = true
                    }
                }

                // Total Section
                Section(header: Text("Total")) {
                    HStack {
                        Text("Amount Due")
                        Spacer()
                        Text(vm.totalAmount.sarFormatted())
                            .font(.title2)
                            .bold()
                    }
                }
            }
            .navigationTitle("New Invoice")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") { createInvoice() }
                        .disabled(!isFormValid)
                }

                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
            .sheet(isPresented: $showCustomerPicker) {
                CustomerSelectionSheet(
                    customers: businessPartnerVM.filteredCustomers,
                    selectedCustomer: $vm.selectedCustomer
                )
            }
            .sheet(isPresented: $showInventoryPicker) {
                InventorySelectionSheet(
                    inventory: inventoryVM.items,
                    onSelect: addInventoryItem
                )
            }
        }
    }

    private var isFormValid: Bool {
        vm.selectedCustomer != nil && !vm.invoiceItems.isEmpty
    }

    private func addInventoryItem(_ item: InventoryItem) {
        vm.addItem(
            inventoryItem: item,
            quantity: 1, // Default quantity
            price: item.salesPrice // Default to inventory price
        )
    }

    private func createInvoice() {
        Task {
            let result = await vm.createInvoice()
            switch result {
            case .success:
                dismiss()
            case .failure(let error as NSError):
                handleInvoiceError(error)
            }
        }
    }

    private func handleInvoiceError(_ error: NSError) {
        switch error.code {
        case 404:
            errorMessage = "One of the items is no longer available"
        case 409:
            errorMessage = "Insufficient stock: \(error.localizedDescription)"
        default:
            errorMessage = "Invoice creation failed: \(error.localizedDescription)"
        }
        showError = true
    }

}

// Subcomponents
struct InvoiceItemRow: View {
    let item: InvoiceItem
    var onPriceChange: (Double) -> Void
    var onQuantityChange: (Int) -> Void

    @State private var price: String
    @State private var quantity: String

    init(item: InvoiceItem, onPriceChange: @escaping (Double) -> Void, onQuantityChange: @escaping (Int) -> Void) {
        self.item = item
        self.onPriceChange = onPriceChange
        self.onQuantityChange = onQuantityChange
        _price = State(initialValue: String(format: "%.2f", item.unitPrice))
        _quantity = State(initialValue: String(item.quantity))
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text(item.name)
                .font(.headline)

            HStack {
                TextField("Price", text: $price)
                    .keyboardType(.decimalPad)
                    .onChange(of: price) { _, newValue in
                        if let value = Double(newValue) {
                            onPriceChange(value)
                        }
                    }
                    .frame(width: 100)

                TextField("Qty", text: $quantity)
                    .keyboardType(.numberPad)
                    .onChange(of: quantity) { _, newValue in
                        if let value = Int(newValue) {
                            onQuantityChange(value)
                        }
                    }
                    .frame(width: 60)

                Spacer()

                Text(item.totalPrice.sarFormatted())
            }
        }
    }
}

struct InventorySelectionSheet: View {
    let inventory: [InventoryItem]
    var onSelect: (InventoryItem) -> Void
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            List(inventory) { item in
                Button {
                    onSelect(item)
                    dismiss()
                } label: {
                    HStack {
                        Text(item.displayName)
                        Spacer()
                        Text(item.salesPrice.sarFormatted())
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Select Item")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

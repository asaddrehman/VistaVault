import SwiftUI

struct InventoryDetailView: View {
    @ObservedObject var vm: InventoryViewModel
    @ObservedObject var unitsVM: UnitsViewModel
    @StateObject private var valuationVM = ValuationClassViewModel()
    @Binding var item: InventoryItem?
    @Environment(\.dismiss) var dismiss

    @State private var productCode = ""
    @State private var name = ""
    @State private var descriptionText = ""
    @State private var displayName = ""
    @State private var selectedUnitId = ""
    @State private var selectedValuationClassId = ""
    @State private var salesPrice = ""
    @State private var purchasePrice = ""
    @State private var quantity = ""
    @State private var isInitialInventory = false
    @State private var showInitialInventoryAlert = false

    var isEditing: Bool {
        item != nil
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Basic Information")) {
                    TextField("Product Code *", text: $productCode)
                        .textInputAutocapitalization(.characters)
                    TextField("Internal Name *", text: $name)
                    TextField("Display Name *", text: $displayName)
                    TextField("Description", text: $descriptionText, axis: .vertical)
                        .lineLimit(2...4)
                }

                Section(header: Text("Classification")) {
                    Picker("Unit Type *", selection: $selectedUnitId) {
                        if unitsVM.units.isEmpty {
                            Text("No Units Available").tag("")
                        } else {
                            Text("Select Unit").tag("")
                            ForEach(unitsVM.units) { unit in
                                Text(unit.name).tag(unit.id ?? "")
                            }
                        }
                    }
                    
                    Picker("Valuation Class", selection: $selectedValuationClassId) {
                        Text("None").tag("")
                        ForEach(valuationVM.valuationClasses.filter { $0.isActive }) { valuationClass in
                            Text(valuationClass.name).tag(valuationClass.id ?? "")
                        }
                    }
                }

                Section(header: Text("Pricing")) {
                    HStack {
                        Text("Sales Price *")
                        Spacer()
                        TextField("0.00", text: $salesPrice)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Purchase Price *")
                        Spacer()
                        TextField("0.00", text: $purchasePrice)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                }

                Section(header: Text("Inventory")) {
                    HStack {
                        Text("Available Quantity *")
                        Spacer()
                        TextField("0", text: $quantity)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    if !isEditing && !selectedValuationClassId.isEmpty {
                        Toggle("Create Initial Inventory Entry", isOn: $isInitialInventory)
                            .onChange(of: isInitialInventory) { _, newValue in
                                if newValue {
                                    showInitialInventoryAlert = true
                                }
                            }
                    }
                }

                Section {
                    NavigationLink {
                        UnitListView()
                    } label: {
                        Label("Manage Units", systemImage: "ruler.fill")
                    }
                    
                    NavigationLink {
                        ValuationClassListView()
                    } label: {
                        Label("Manage Valuation Classes", systemImage: "tag.fill")
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Item" : "New Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Update" : "Save") {
                        saveItem()
                    }
                    .disabled(!formIsValid)
                }
            }
            .alert("Initial Inventory Entry", isPresented: $showInitialInventoryAlert) {
                Button("OK") { }
            } message: {
                Text("This will create a journal entry debiting the Inventory account and crediting Owner's Equity for the purchase price × quantity.")
            }
            .onAppear {
                loadExistingData()
                unitsVM.setupListener()
                valuationVM.refreshData()
            }
        }
    }

    private var formIsValid: Bool {
        !productCode.isEmpty &&
            !name.isEmpty &&
            !displayName.isEmpty &&
            !salesPrice.isEmpty &&
            !purchasePrice.isEmpty &&
            !quantity.isEmpty &&
            !selectedUnitId.isEmpty
    }

    private func loadExistingData() {
        if let existingItem = item {
            productCode = existingItem.productCode
            name = existingItem.name
            descriptionText = existingItem.description
            displayName = existingItem.displayName
            selectedUnitId = existingItem.unitId
            selectedValuationClassId = existingItem.valuationClassId ?? ""
            salesPrice = String(existingItem.salesPrice)
            purchasePrice = String(existingItem.purchasePrice)
            quantity = String(existingItem.availableQuantity)
        }

        // Set default unit if none selected
        if selectedUnitId.isEmpty, !unitsVM.units.isEmpty {
            selectedUnitId = unitsVM.units[0].id ?? ""
        }
    }

    private func saveItem() {
        guard let sales = Double(salesPrice),
              let purchase = Double(purchasePrice),
              let qty = Int(quantity),
              !selectedUnitId.isEmpty else { return }

        let inventoryItem = InventoryItem(
            id: item?.id,
            productCode: productCode,
            name: name,
            description: descriptionText,
            displayName: displayName,
            unitId: selectedUnitId,
            valuationClassId: selectedValuationClassId.isEmpty ? nil : selectedValuationClassId,
            salesPrice: sales,
            purchasePrice: purchase,
            availableQuantity: qty
        )

        if isEditing {
            _ = vm.updateItem(inventoryItem)
            dismiss()
        } else {
            _ = vm.addItem(inventoryItem)
            
            // Create initial inventory entry if requested
            if isInitialInventory, 
               !selectedValuationClassId.isEmpty,
               let valuationClass = valuationVM.valuationClasses.first(where: { $0.id == selectedValuationClassId }) {
                Task {
                    do {
                        try await InventoryService.shared.createInitialInventoryEntry(
                            item: inventoryItem,
                            quantity: qty,
                            valuationClass: valuationClass
                        )
                    } catch {
                        print("Error creating initial inventory entry: \(error)")
                    }
                }
            }
            
            dismiss()
        }
    }
}

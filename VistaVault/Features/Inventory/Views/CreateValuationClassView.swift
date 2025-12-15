import SwiftUI

struct CreateValuationClassView: View {
    @ObservedObject var viewModel: ValuationClassViewModel
    @StateObject private var accountVM = ChartOfAccountsViewModel()
    @Environment(\.dismiss) var dismiss
    
    @State private var classCode = ""
    @State private var name = ""
    @State private var description = ""
    @State private var inventoryAccount: ChartOfAccount?
    @State private var cogsAccount: ChartOfAccount?
    @State private var isActive = true
    @State private var showInventoryPicker = false
    @State private var showCOGSPicker = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isProcessing = false
    
    var canSubmit: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !classCode.isEmpty &&
        inventoryAccount != nil &&
        cogsAccount != nil
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Basic Information") {
                    TextField("Class Code", text: $classCode)
                        .disabled(true)
                    
                    TextField("Name", text: $name)
                        .autocapitalization(.words)
                    
                    TextField("Description (Optional)", text: $description, axis: .vertical)
                        .lineLimit(2...4)
                    
                    Toggle("Active", isOn: $isActive)
                }
                
                Section("GL Accounts") {
                    accountSelection(
                        title: "Inventory Account",
                        account: inventoryAccount,
                        showPicker: $showInventoryPicker
                    )
                    
                    accountSelection(
                        title: "COGS Account",
                        account: cogsAccount,
                        showPicker: $showCOGSPicker
                    )
                }
            }
            .navigationTitle("New Valuation Class")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        createValuationClass()
                    }
                    .disabled(!canSubmit || isProcessing)
                }
            }
            .sheet(isPresented: $showInventoryPicker) {
                AccountPickerForInventorySheet(
                    accounts: accountVM.assetAccounts,
                    selectedAccount: $inventoryAccount
                )
            }
            .sheet(isPresented: $showCOGSPicker) {
                AccountPickerForInventorySheet(
                    accounts: accountVM.cogsAccounts,
                    selectedAccount: $cogsAccount
                )
            }
            .alert("Error", isPresented: $showError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
            .onAppear {
                accountVM.fetchAccounts()
                classCode = viewModel.generateClassCode()
            }
        }
    }
    
    private func accountSelection(title: String, account: ChartOfAccount?, showPicker: Binding<Bool>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            if let account = account {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(account.accountName)
                            .font(.body)
                        Text(account.accountCode)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Button("Change") {
                        showPicker.wrappedValue = true
                    }
                    .font(.caption)
                }
            } else {
                Button("Select Account") {
                    showPicker.wrappedValue = true
                }
            }
        }
    }
    
    private func createValuationClass() {
        guard let userId = LocalAuthManager.shared.currentUserId,
              let inventoryAccountId = inventoryAccount?.id,
              let cogsAccountId = cogsAccount?.id else {
            errorMessage = "Please fill in all required fields"
            showError = true
            return
        }
        
        isProcessing = true
        
        let valuationClass = ValuationClass(
            id: UUID().uuidString,
            userId: userId,
            classCode: classCode,
            name: name.trimmingCharacters(in: .whitespaces),
            description: description.isEmpty ? nil : description,
            inventoryAccountId: inventoryAccountId,
            cogsAccountId: cogsAccountId,
            isActive: isActive,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        Task {
            do {
                try await viewModel.createValuationClass(valuationClass)
                await MainActor.run {
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isProcessing = false
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
}

struct AccountPickerForInventorySheet: View {
    let accounts: [ChartOfAccount]
    @Binding var selectedAccount: ChartOfAccount?
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""
    
    var filteredAccounts: [ChartOfAccount] {
        if searchText.isEmpty {
            return accounts
        }
        return accounts.filter {
            $0.accountName.localizedCaseInsensitiveContains(searchText) ||
            $0.accountCode.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationStack {
            List(filteredAccounts) { account in
                Button {
                    selectedAccount = account
                    dismiss()
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(account.accountName)
                            .font(.headline)
                        HStack {
                            Text(account.accountCode)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("•")
                                .foregroundColor(.secondary)
                            Text(account.accountType.rawValue)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search accounts")
            .navigationTitle("Select Account")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

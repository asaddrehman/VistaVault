import SwiftUI

struct AccountDetailView: View {
    let account: ChartOfAccount
    @ObservedObject var viewModel: ChartOfAccountsViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var isEditing = false
    @State private var showDeleteAlert = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header Card
                accountHeaderCard
                
                // Details Card
                accountDetailsCard
                
                // Balance Information Card
                balanceInformationCard
                
                // Actions
                if isEditing {
                    editingActions
                } else {
                    viewingActions
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(account.accountName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                if !isEditing {
                    Button("Edit") {
                        isEditing = true
                    }
                }
            }
        }
        .sheet(isPresented: $isEditing) {
            EditAccountView(account: account, viewModel: viewModel)
        }
        .alert("Delete Account", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteAccount()
            }
        } message: {
            if abs(account.balance) >= AppConstants.Accounting.floatingPointTolerance {
                Text("This account has a non-zero balance (\(account.balance.formatted(.currency(code: "USD")))). Please clear the balance before deleting.")
            } else {
                Text("Are you sure you want to delete this account? This action cannot be undone.")
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    // MARK: - Header Card
    
    private var accountHeaderCard: some View {
        VStack(spacing: 12) {
            Image(systemName: account.accountType.icon)
                .font(.system(size: 60))
                .foregroundColor(AppConstants.Colors.brandPrimary)
            
            Text(account.accountName)
                .font(.title2.bold())
                .multilineTextAlignment(.center)
            
            Text(account.accountCode)
                .font(.headline)
                .foregroundColor(.secondary)
            
            HStack(spacing: 4) {
                Text(account.accountType.rawValue)
                    .font(.subheadline)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(AppConstants.Colors.brandPrimary.opacity(0.1))
                    .foregroundColor(AppConstants.Colors.brandPrimary)
                    .cornerRadius(8)
                
                if !account.isActive {
                    Text("Inactive")
                        .font(.subheadline)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.red.opacity(0.1))
                        .foregroundColor(.red)
                        .cornerRadius(8)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Color(.systemBackground))
        .cornerRadius(AppConstants.CornerRadius.large)
        .shadow(radius: 2)
    }
    
    // MARK: - Details Card
    
    private var accountDetailsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Account Details", systemImage: "info.circle")
                .font(.headline)
            
            DetailRow(label: "Account Code", value: account.accountCode, icon: "number")
            Divider()
            
            DetailRow(label: "Account Type", value: account.accountType.rawValue, icon: "tag")
            Divider()
            
            DetailRow(label: "Category", value: account.accountType.category.rawValue, icon: "folder")
            Divider()
            
            DetailRow(label: "Normal Balance", value: account.normalBalance.rawValue, icon: "scale.3d")
            
            if let description = account.description, !description.isEmpty {
                Divider()
                VStack(alignment: .leading, spacing: 8) {
                    Label("Description", systemImage: "text.alignleft")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(description)
                        .font(.body)
                }
            }
            
            Divider()
            
            HStack {
                Label("Status", systemImage: "checkmark.circle")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(account.isActive ? "Active" : "Inactive")
                    .font(.body)
                    .foregroundColor(account.isActive ? .green : .red)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(AppConstants.CornerRadius.large)
        .shadow(radius: 2)
    }
    
    // MARK: - Balance Information Card
    
    private var balanceInformationCard: some View {
        VStack(spacing: 16) {
            Label("Balance Information", systemImage: "dollarsign.circle")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Current Balance")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(account.balance, format: .currency(code: "USD"))
                        .font(.title2.bold())
                        .foregroundColor(account.balance >= 0 ? .primary : .red)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Normal Balance")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(account.normalBalance.rawValue)
                        .font(.headline)
                        .foregroundColor(
                            account.normalBalance == .debit ?
                            AppConstants.Colors.debitColor : AppConstants.Colors.creditColor
                        )
                }
            }
            
            if let createdAt = account.createdAt {
                Divider()
                HStack {
                    Text("Created")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(createdAt, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if let updatedAt = account.updatedAt {
                HStack {
                    Text("Last Updated")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(updatedAt, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(AppConstants.CornerRadius.large)
        .shadow(radius: 2)
    }
    
    // MARK: - Actions
    
    private var viewingActions: some View {
        VStack(spacing: 12) {
            Button(action: { isEditing = true }) {
                Label("Edit Account", systemImage: "pencil")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppConstants.Colors.brandPrimary)
                    .cornerRadius(AppConstants.CornerRadius.medium)
            }
            
            Button(action: { showDeleteAlert = true }) {
                Label("Delete Account", systemImage: "trash")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(AppConstants.CornerRadius.medium)
            }
        }
    }
    
    private var editingActions: some View {
        EmptyView()
    }
    
    // MARK: - Helper Methods
    
    private func deleteAccount() {
        // Check if balance is zero
        guard abs(account.balance) < AppConstants.Accounting.floatingPointTolerance else {
            errorMessage = "Cannot delete account with non-zero balance"
            showError = true
            return
        }
        
        Task {
            do {
                try await viewModel.deleteAccount(account)
                await MainActor.run {
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
}

// MARK: - Edit Account View

struct EditAccountView: View {
    let account: ChartOfAccount
    @ObservedObject var viewModel: ChartOfAccountsViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var accountName: String
    @State private var accountCode: String
    @State private var accountType: ChartOfAccount.AccountType
    @State private var description: String
    @State private var isActive: Bool
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isProcessing = false
    @FocusState private var focusedField: Field?
    
    enum Field {
        case name, code, description
    }
    
    init(account: ChartOfAccount, viewModel: ChartOfAccountsViewModel) {
        self.account = account
        self.viewModel = viewModel
        _accountName = State(initialValue: account.accountName)
        _accountCode = State(initialValue: account.accountCode)
        _accountType = State(initialValue: account.accountType)
        _description = State(initialValue: account.description ?? "")
        _isActive = State(initialValue: account.isActive)
    }
    
    var hasChanges: Bool {
        accountName != account.accountName ||
        accountCode != account.accountCode ||
        accountType != account.accountType ||
        description != (account.description ?? "") ||
        isActive != account.isActive
    }
    
    var canSubmit: Bool {
        hasChanges &&
        !accountName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !accountCode.isEmpty &&
        accountCode.hasPrefix(accountType.codePrefix)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Account Information") {
                    TextField("Account Name", text: $accountName)
                        .focused($focusedField, equals: .name)
                        .autocapitalization(.words)
                    
                    TextField("Account Code", text: $accountCode)
                        .focused($focusedField, equals: .code)
                        .keyboardType(.numberPad)
                        .disabled(true) // Typically don't allow changing account codes
                    
                    if !accountCode.isEmpty && !accountCode.hasPrefix(accountType.codePrefix) {
                        Text("Code must start with \(accountType.codePrefix) for \(accountType.category.rawValue)")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                
                Section("Account Type") {
                    Picker("Type", selection: $accountType) {
                        ForEach(ChartOfAccount.AccountType.allCases, id: \.self) { type in
                            VStack(alignment: .leading) {
                                Text(type.rawValue)
                                Text(type.category.rawValue)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .tag(type)
                        }
                    }
                    .disabled(true) // Typically don't allow changing account types
                    
                    HStack {
                        Text("Normal Balance")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(accountType.category.normalBalance.rawValue)
                            .foregroundColor(
                                accountType.category.normalBalance == .debit ?
                                AppConstants.Colors.debitColor : AppConstants.Colors.creditColor
                            )
                    }
                }
                
                Section("Additional Details") {
                    TextField("Description (Optional)", text: $description, axis: .vertical)
                        .focused($focusedField, equals: .description)
                        .lineLimit(3...5)
                    
                    Toggle("Active", isOn: $isActive)
                }
                
                Section {
                    HStack {
                        Text("Current Balance")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(account.balance, format: .currency(code: "USD"))
                            .fontWeight(.bold)
                    }
                } footer: {
                    Text("Account balance cannot be modified directly. Use journal entries to adjust balances.")
                        .font(.caption)
                }
            }
            .navigationTitle("Edit Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        updateAccount()
                    }
                    .disabled(!canSubmit || isProcessing)
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func updateAccount() {
        isProcessing = true
        
        var updatedAccount = account
        updatedAccount.accountName = accountName.trimmingCharacters(in: .whitespaces)
        updatedAccount.accountCode = accountCode
        updatedAccount.accountType = accountType
        updatedAccount.description = description.isEmpty ? nil : description
        updatedAccount.isActive = isActive
        updatedAccount.updatedAt = Date()
        
        Task {
            do {
                try await viewModel.updateAccount(updatedAccount)
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

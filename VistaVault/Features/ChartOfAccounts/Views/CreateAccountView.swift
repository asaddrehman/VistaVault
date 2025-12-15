import SwiftUI

struct CreateAccountView: View {
    @ObservedObject var viewModel: ChartOfAccountsViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var accountName = ""
    @State private var accountCode = ""
    @State private var accountType: ChartOfAccount.AccountType = .currentAssets
    @State private var description = ""
    @State private var isActive = true
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isProcessing = false
    @FocusState private var focusedField: Field?
    
    enum Field {
        case name, code, description
    }
    
    var suggestedAccountCode: String {
        let prefix = accountType.codePrefix
        let existingCodes = viewModel.accounts
            .filter { $0.accountType.category == accountType.category }
            .compactMap { account -> Int? in
                guard account.accountCode.hasPrefix(prefix) else { return nil }
                return Int(account.accountCode.dropFirst())
            }
        
        let maxCode = existingCodes.max() ?? Int("\(prefix)000")!
        return String(maxCode + 1)
    }
    
    var canSubmit: Bool {
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
                    
                    HStack {
                        TextField("Account Code", text: $accountCode)
                            .focused($focusedField, equals: .code)
                            .keyboardType(.numberPad)
                        
                        Button("Suggest") {
                            accountCode = suggestedAccountCode
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                    }
                    
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
                    
                    HStack {
                        Text("Code Prefix")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(accountType.codePrefix + "XXX")
                            .font(.system(.body, design: .monospaced))
                    }
                }
                
                Section("Additional Details") {
                    TextField("Description (Optional)", text: $description, axis: .vertical)
                        .focused($focusedField, equals: .description)
                        .lineLimit(3...5)
                    
                    Toggle("Active", isOn: $isActive)
                }
            }
            .navigationTitle("New Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        createAccount()
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
    
    private func createAccount() {
        guard let userId = LocalAuthManager.shared.currentUserId else {
            errorMessage = "User not authenticated"
            showError = true
            return
        }
        
        isProcessing = true
        
        let account = ChartOfAccount(
            id: UUID().uuidString,
            userId: userId,
            accountCode: accountCode,
            accountName: accountName.trimmingCharacters(in: .whitespaces),
            accountType: accountType,
            parentAccountId: nil,
            balance: 0.0,
            isActive: isActive,
            description: description.isEmpty ? nil : description,
            level: 1,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        Task {
            do {
                try await viewModel.createAccount(account)
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

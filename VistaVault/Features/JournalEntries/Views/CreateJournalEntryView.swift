import SwiftUI

struct CreateJournalEntryView: View {
    @ObservedObject var viewModel: JournalEntryViewModel
    @StateObject private var accountVM = ChartOfAccountsViewModel()
    @Environment(\.dismiss) var dismiss
    
    @State private var entryNumber = ""
    @State private var entryDate = Date()
    @State private var description = ""
    @State private var lineItems: [LineItemInput] = []
    @State private var showAddLineItem = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isProcessing = false
    
    struct LineItemInput: Identifiable {
        let id = UUID()
        var account: ChartOfAccount?
        var type: JournalLineItem.EntryType = .debit
        var amount: String = ""
        var memo: String = ""
    }
    
    var totalDebits: Double {
        lineItems
            .filter { $0.type == .debit }
            .compactMap { Double($0.amount) }
            .reduce(0, +)
    }
    
    var totalCredits: Double {
        lineItems
            .filter { $0.type == .credit }
            .compactMap { Double($0.amount) }
            .reduce(0, +)
    }
    
    var isBalanced: Bool {
        abs(totalDebits - totalCredits) < AppConstants.Accounting.floatingPointTolerance
    }
    
    var canSubmit: Bool {
        !entryNumber.isEmpty &&
        !description.isEmpty &&
        lineItems.count >= 2 &&
        lineItems.allSatisfy { $0.account != nil && !$0.amount.isEmpty && (Double($0.amount) ?? 0) > 0 } &&
        isBalanced
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    headerSection
                    balanceSummarySection
                    lineItemsSection
                    addLineItemButton
                    submitButton
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("New Journal Entry")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.red)
                }
            }
            .sheet(isPresented: $showAddLineItem) {
                AddLineItemSheet(
                    accounts: accountVM.accounts,
                    lineItems: $lineItems
                )
            }
            .alert("Journal Entry Error", isPresented: $showError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
            .onAppear {
                accountVM.fetchAccounts()
                generateEntryNumber()
            }
        }
    }
    
    // MARK: - Sections
    
    private var headerSection: some View {
        SectionCard(title: "Entry Details", systemImage: "doc.text.fill") {
            VStack(spacing: 12) {
                TextField("Entry Number", text: $entryNumber)
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(AppConstants.CornerRadius.medium)
                    .disabled(true)
                
                DatePicker("Entry Date", selection: $entryDate, displayedComponents: .date)
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(AppConstants.CornerRadius.medium)
                
                TextField("Description", text: $description, axis: .vertical)
                    .lineLimit(2...4)
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(AppConstants.CornerRadius.medium)
            }
        }
        .padding(.horizontal)
    }
    
    private var balanceSummarySection: some View {
        HStack(spacing: 16) {
            VStack(spacing: 4) {
                Text("Debits")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(totalDebits, format: .currency(code: "USD"))
                    .font(.title3.bold())
                    .foregroundColor(AppConstants.Colors.debitColor)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(AppConstants.CornerRadius.medium)
            
            VStack(spacing: 4) {
                Image(systemName: isBalanced ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                    .foregroundColor(isBalanced ? .green : .orange)
                    .font(.title3)
            }
            .frame(width: 44)
            
            VStack(spacing: 4) {
                Text("Credits")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(totalCredits, format: .currency(code: "USD"))
                    .font(.title3.bold())
                    .foregroundColor(AppConstants.Colors.creditColor)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(AppConstants.CornerRadius.medium)
        }
        .padding(.horizontal)
    }
    
    private var lineItemsSection: some View {
        SectionCard(title: "Line Items", systemImage: "list.bullet") {
            if lineItems.isEmpty {
                Text("No line items yet. Add at least 2 line items.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(AppConstants.CornerRadius.medium)
            } else {
                VStack(spacing: 12) {
                    ForEach(Array(lineItems.enumerated()), id: \.element.id) { index, item in
                        LineItemCardView(
                            item: item,
                            onDelete: {
                                lineItems.remove(at: index)
                            }
                        )
                    }
                }
            }
        }
        .padding(.horizontal)
    }
    
    private var addLineItemButton: some View {
        Button(action: { showAddLineItem = true }) {
            Label("Add Line Item", systemImage: "plus.circle.fill")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(AppConstants.CornerRadius.medium)
        }
        .padding(.horizontal)
    }
    
    private var submitButton: some View {
        Button(action: createEntry) {
            HStack {
                if isProcessing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Create Journal Entry")
                        .font(.headline.weight(.semibold))
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(canSubmit ? AppConstants.Colors.brandPrimary : Color.gray)
            .foregroundColor(.white)
            .cornerRadius(AppConstants.CornerRadius.medium)
        }
        .disabled(!canSubmit || isProcessing)
        .padding(.horizontal)
    }
    
    // MARK: - Helpers
    
    private func generateEntryNumber() {
        Task {
            do {
                let number = try await viewModel.generateEntryNumber()
                await MainActor.run {
                    entryNumber = number
                }
            } catch {
                print("Error generating entry number: \(error)")
            }
        }
    }
    
    private func createEntry() {
        guard let userId = LocalAuthManager.shared.currentUserId else {
            errorMessage = "Authentication required"
            showError = true
            return
        }
        
        isProcessing = true
        
        let journalLineItems = lineItems.compactMap { item -> JournalLineItem? in
            guard let account = item.account,
                  let accountId = account.id,
                  let amount = Double(item.amount) else {
                return nil
            }
            
            return JournalLineItem(
                id: UUID().uuidString,
                accountId: accountId,
                accountName: account.accountName,
                type: item.type,
                amount: amount,
                memo: item.memo.isEmpty ? nil : item.memo
            )
        }
        
        let entry = JournalEntry(
            id: UUID().uuidString,
            entryNumber: entryNumber,
            date: entryDate,
            description: description,
            userId: userId,
            lineItems: journalLineItems,
            createdAt: Date()
        )
        
        Task {
            let result = await viewModel.createJournalEntry(entry)
            
            await MainActor.run {
                isProcessing = false
                
                switch result {
                case .success:
                    viewModel.fetchAllJournalEntries()
                    dismiss()
                case .failure(let error):
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
}

// MARK: - Supporting Views

struct LineItemCardView: View {
    let item: CreateJournalEntryView.LineItemInput
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: item.type == .debit ? "minus.circle.fill" : "plus.circle.fill")
                .font(.title2)
                .foregroundColor(item.type == .debit ? AppConstants.Colors.debitColor : AppConstants.Colors.creditColor)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.account?.accountName ?? "Unknown")
                    .font(.headline)
                
                Text(item.type.rawValue)
                    .font(.caption)
                    .foregroundColor(item.type == .debit ? AppConstants.Colors.debitColor : AppConstants.Colors.creditColor)
                
                if !item.memo.isEmpty {
                    Text(item.memo)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                if let amount = Double(item.amount) {
                    Text(amount, format: .currency(code: "USD"))
                        .font(.headline)
                        .foregroundColor(item.type == .debit ? AppConstants.Colors.debitColor : AppConstants.Colors.creditColor)
                }
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(AppConstants.CornerRadius.medium)
    }
}

struct AddLineItemSheet: View {
    let accounts: [ChartOfAccount]
    @Binding var lineItems: [CreateJournalEntryView.LineItemInput]
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedAccount: ChartOfAccount?
    @State private var selectedType: JournalLineItem.EntryType = .debit
    @State private var amount = ""
    @State private var memo = ""
    @State private var showAccountPicker = false
    @FocusState private var focusedField: Field?
    
    enum Field { case amount, memo }
    
    var canAdd: Bool {
        selectedAccount != nil &&
        !amount.isEmpty &&
        (Double(amount) ?? 0) > 0
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Account") {
                    if let account = selectedAccount {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(account.accountName)
                                    .font(.headline)
                                Text(account.accountCode)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Button("Change") {
                                showAccountPicker = true
                            }
                        }
                    } else {
                        Button("Select Account") {
                            showAccountPicker = true
                        }
                    }
                }
                
                Section("Type") {
                    Picker("Entry Type", selection: $selectedType) {
                        Text("Debit").tag(JournalLineItem.EntryType.debit)
                        Text("Credit").tag(JournalLineItem.EntryType.credit)
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Amount") {
                    TextField("0.00", text: $amount)
                        .keyboardType(.decimalPad)
                        .focused($focusedField, equals: .amount)
                }
                
                Section("Memo (Optional)") {
                    TextField("Add a memo...", text: $memo, axis: .vertical)
                        .lineLimit(2...4)
                        .focused($focusedField, equals: .memo)
                }
            }
            .navigationTitle("Add Line Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addLineItem()
                    }
                    .disabled(!canAdd)
                }
            }
            .sheet(isPresented: $showAccountPicker) {
                AccountPickerSheet(
                    accounts: accounts,
                    selectedAccount: $selectedAccount
                )
            }
        }
    }
    
    private func addLineItem() {
        let newItem = CreateJournalEntryView.LineItemInput(
            account: selectedAccount,
            type: selectedType,
            amount: amount,
            memo: memo
        )
        lineItems.append(newItem)
        dismiss()
    }
}

private struct AccountPickerSheet: View {
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

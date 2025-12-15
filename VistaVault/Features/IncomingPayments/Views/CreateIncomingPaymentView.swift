import SwiftUI

struct CreateIncomingPaymentView: View {
    @ObservedObject var viewModel: IncomingPaymentViewModel
    @ObservedObject var businessPartnerVM: BusinessPartnerViewModel
    @StateObject private var accountVM = ChartOfAccountsViewModel()
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedCustomer: BusinessPartner?
    @State private var selectedAccount: ChartOfAccount?
    @State private var amount = ""
    @State private var paymentDate = Date()
    @State private var notes = ""
    @State private var referenceNumber = ""
    @State private var showCustomerPicker = false
    @State private var showAccountPicker = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isProcessing = false
    @FocusState private var focusedField: Field?
    
    enum Field { case amount, notes, reference }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    customerSection
                    accountSection
                    amountSection
                    referenceSection
                    notesSection
                    submitButton
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("New Incoming Payment")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.red)
                }
            }
            .sheet(isPresented: $showCustomerPicker) {
                CustomerSelectionSheet(
                    customers: businessPartnerVM.customers,
                    selectedCustomer: $selectedCustomer
                )
            }
            .sheet(isPresented: $showAccountPicker) {
                AccountSelectionSheet(
                    accounts: accountVM.cashAndBankAccounts,
                    selectedAccount: $selectedAccount
                )
            }
            .alert("Payment Error", isPresented: $showError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
            .onAppear {
                accountVM.fetchAccounts()
            }
        }
    }
    
    // MARK: - Sections
    
    private var customerSection: some View {
        SectionCard(title: "Customer", systemImage: "person.fill") {
            if let customer = selectedCustomer {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(customer.displayName)
                            .font(.headline)
                        if let email = customer.email {
                            Text(email)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    Spacer()
                    Button(action: { selectedCustomer = nil }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(AppConstants.CornerRadius.medium)
            } else {
                Button(action: { showCustomerPicker = true }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Select Customer")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(AppConstants.CornerRadius.medium)
                }
            }
        }
        .padding(.horizontal)
    }
    
    private var accountSection: some View {
        SectionCard(title: "Received In Account", systemImage: "building.columns.fill") {
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
                    Button(action: { selectedAccount = nil }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(AppConstants.CornerRadius.medium)
            } else {
                Button(action: { showAccountPicker = true }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Select Account")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(AppConstants.CornerRadius.medium)
                }
            }
        }
        .padding(.horizontal)
    }
    
    private var amountSection: some View {
        SectionCard(title: "Amount", systemImage: "dollarsign.circle.fill") {
            VStack(spacing: 12) {
                TextField("0.00", text: $amount)
                    .keyboardType(.decimalPad)
                    .font(.system(size: 32, weight: .bold))
                    .multilineTextAlignment(.center)
                    .focused($focusedField, equals: .amount)
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(AppConstants.CornerRadius.medium)
                
                DatePicker("Payment Date", selection: $paymentDate, displayedComponents: .date)
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(AppConstants.CornerRadius.medium)
            }
        }
        .padding(.horizontal)
    }
    
    private var referenceSection: some View {
        SectionCard(title: "Reference Number (Optional)", systemImage: "number.circle.fill") {
            TextField("Reference #", text: $referenceNumber)
                .focused($focusedField, equals: .reference)
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(AppConstants.CornerRadius.medium)
        }
        .padding(.horizontal)
    }
    
    private var notesSection: some View {
        SectionCard(title: "Notes (Optional)", systemImage: "note.text") {
            TextField("Add notes here...", text: $notes, axis: .vertical)
                .lineLimit(3...6)
                .focused($focusedField, equals: .notes)
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(AppConstants.CornerRadius.medium)
        }
        .padding(.horizontal)
    }
    
    private var submitButton: some View {
        Button(action: processPayment) {
            HStack {
                if isProcessing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Record Payment")
                        .font(.headline.weight(.semibold))
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(canSubmit ? AppConstants.Colors.creditColor : Color.gray)
            .foregroundColor(.white)
            .cornerRadius(AppConstants.CornerRadius.medium)
        }
        .disabled(!canSubmit || isProcessing)
        .padding(.horizontal)
    }
    
    // MARK: - Helpers
    
    private var canSubmit: Bool {
        selectedCustomer != nil &&
        selectedAccount != nil &&
        !amount.isEmpty &&
        (Double(amount) ?? 0) > 0
    }
    
    private func processPayment() {
        guard let customer = selectedCustomer,
              let account = selectedAccount,
              let customerId = customer.id,
              let accountId = account.id,
              let amountValue = Double(amount),
              amountValue > 0 else {
            errorMessage = "Please fill in all required fields"
            showError = true
            return
        }
        
        isProcessing = true
        
        Task {
            let params = IncomingPaymentViewModel.PaymentParams(
                customerId: customerId,
                customerName: customer.displayName,
                receivedInAccountId: accountId,
                amount: amountValue,
                date: paymentDate,
                notes: notes.isEmpty ? nil : notes,
                referenceNumber: referenceNumber.isEmpty ? nil : referenceNumber
            )
            
            let result = await viewModel.createPayment(params)
            
            await MainActor.run {
                isProcessing = false
                
                switch result {
                case .success:
                    viewModel.fetchAllPayments()
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

struct CustomerSelectionSheet: View {
    let customers: [BusinessPartner]
    @Binding var selectedCustomer: BusinessPartner?
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            List(customers) { customer in
                Button {
                    selectedCustomer = customer
                    dismiss()
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(customer.displayName)
                            .font(.headline)
                        if let email = customer.email {
                            Text(email)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Select Customer")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

struct AccountSelectionSheet: View {
    let accounts: [ChartOfAccount]
    @Binding var selectedAccount: ChartOfAccount?
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            List(accounts) { account in
                Button {
                    selectedAccount = account
                    dismiss()
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(account.accountName)
                            .font(.headline)
                        Text(account.accountCode)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Select Account")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

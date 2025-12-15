import SwiftUI

struct CreateOutgoingPaymentView: View {
    @ObservedObject var viewModel: OutgoingPaymentViewModel
    @ObservedObject var businessPartnerVM: BusinessPartnerViewModel
    @StateObject private var accountVM = ChartOfAccountsViewModel()
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedVendor: BusinessPartner?
    @State private var selectedAccount: ChartOfAccount?
    @State private var amount = ""
    @State private var paymentDate = Date()
    @State private var notes = ""
    @State private var referenceNumber = ""
    @State private var showVendorPicker = false
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
                    vendorSection
                    accountSection
                    amountSection
                    referenceSection
                    notesSection
                    submitButton
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("New Outgoing Payment")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.red)
                }
            }
            .sheet(isPresented: $showVendorPicker) {
                VendorSelectionSheet(
                    vendors: businessPartnerVM.vendors,
                    selectedVendor: $selectedVendor
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
    
    private var vendorSection: some View {
        SectionCard(title: "Vendor", systemImage: "building.2.fill") {
            if let vendor = selectedVendor {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(vendor.displayName)
                            .font(.headline)
                        if let email = vendor.email {
                            Text(email)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    Spacer()
                    Button(action: { selectedVendor = nil }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(AppConstants.CornerRadius.medium)
            } else {
                Button(action: { showVendorPicker = true }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Select Vendor")
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
        SectionCard(title: "Paid From Account", systemImage: "building.columns.fill") {
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
            .background(canSubmit ? AppConstants.Colors.debitColor : Color.gray)
            .foregroundColor(.white)
            .cornerRadius(AppConstants.CornerRadius.medium)
        }
        .disabled(!canSubmit || isProcessing)
        .padding(.horizontal)
    }
    
    // MARK: - Helpers
    
    private var canSubmit: Bool {
        selectedVendor != nil &&
        selectedAccount != nil &&
        !amount.isEmpty &&
        (Double(amount) ?? 0) > 0
    }
    
    private func processPayment() {
        guard let vendor = selectedVendor,
              let account = selectedAccount,
              let vendorId = vendor.id,
              let accountId = account.id,
              let amountValue = Double(amount),
              amountValue > 0 else {
            errorMessage = "Please fill in all required fields"
            showError = true
            return
        }
        
        isProcessing = true
        
        Task {
            let params = OutgoingPaymentViewModel.PaymentParams(
                vendorId: vendorId,
                vendorName: vendor.displayName,
                paidFromAccountId: accountId,
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

struct VendorSelectionSheet: View {
    let vendors: [BusinessPartner]
    @Binding var selectedVendor: BusinessPartner?
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            List(vendors) { vendor in
                Button {
                    selectedVendor = vendor
                    dismiss()
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(vendor.displayName)
                            .font(.headline)
                        if let email = vendor.email {
                            Text(email)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Select Vendor")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

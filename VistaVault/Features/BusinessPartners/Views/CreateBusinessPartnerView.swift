import SwiftUI

struct CreateBusinessPartnerView: View {
    @ObservedObject var viewModel: BusinessPartnerViewModel
    @StateObject private var accountVM = ChartOfAccountsViewModel()
    @Environment(\.dismiss) var dismiss

    @State private var partnerCode = ""
    @State private var name = ""
    @State private var partnerType: BusinessPartner.PartnerType = .customer
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var mobile = ""
    @State private var website = ""
    @State private var address = ""
    @State private var city = ""
    @State private var state = ""
    @State private var postalCode = ""
    @State private var country = ""
    @State private var taxId = ""
    @State private var vatNumber = ""
    @State private var creditLimit = ""
    @State private var paymentTerms = ""
    @State private var discount = ""
    @State private var notes = ""
    @State private var isActive = true
    @State private var selectedAccount: ChartOfAccount?
    @State private var showAccountPicker = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isProcessing = false
    @FocusState private var focusedField: Field?

    enum Field: Hashable {
        case name, firstName, lastName, email, phone, mobile, website
        case address, city, state, postalCode, country
        case taxId, vatNumber, creditLimit, paymentTerms, discount, notes
    }

    var canSubmit: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !partnerCode.isEmpty &&
        selectedAccount != nil
    }

    var body: some View {
        NavigationStack {
            Form {
                basicInformationSection
                contactInformationSection
                addressInformationSection
                financialInformationSection
                taxInformationSection
                additionalDetailsSection
            }
            .navigationTitle("New Business Partner")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        createPartner()
                    }
                    .disabled(!canSubmit || isProcessing)
                }
            }
            .sheet(isPresented: $showAccountPicker) {
                AccountPickerSheet(
                    accounts: accountVM.accounts,
                    selectedAccount: $selectedAccount
                )
            }
            .alert("Error", isPresented: $showError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
            .onAppear {
                accountVM.fetchAccounts()
                generatePartnerCode()
            }
            .onChange(of: partnerType) { _, _ in
                generatePartnerCode()
            }
        }
    }

    // MARK: - Sections

    private var basicInformationSection: some View {
        Section("Basic Information") {
            Picker("Type", selection: $partnerType) {
                ForEach(BusinessPartner.PartnerType.allCases, id: \.self) { type in
                    Label(type.rawValue, systemImage: type.icon)
                        .tag(type)
                }
            }

            TextField("Partner Code", text: $partnerCode)
                .disabled(true)

            TextField("Business Name", text: $name)
                .focused($focusedField, equals: .name)
                .autocapitalization(.words)

            if let account = selectedAccount {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Linked Account")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(account.accountName)
                            .font(.subheadline)
                        Text(account.accountCode)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Button("Change") {
                        showAccountPicker = true
                    }
                    .font(.caption)
                }
            } else {
                Button("Select Linked Account") {
                    showAccountPicker = true
                }
            }

            Toggle("Active", isOn: $isActive)
        }
    }

    private var contactInformationSection: some View {
        Section("Contact Information") {
            TextField("First Name (Optional)", text: $firstName)
                .focused($focusedField, equals: .firstName)
                .autocapitalization(.words)

            TextField("Last Name (Optional)", text: $lastName)
                .focused($focusedField, equals: .lastName)
                .autocapitalization(.words)

            TextField("Email (Optional)", text: $email)
                .focused($focusedField, equals: .email)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)

            TextField("Phone (Optional)", text: $phone)
                .focused($focusedField, equals: .phone)
                .keyboardType(.phonePad)

            TextField("Mobile (Optional)", text: $mobile)
                .focused($focusedField, equals: .mobile)
                .keyboardType(.phonePad)

            TextField("Website (Optional)", text: $website)
                .focused($focusedField, equals: .website)
                .keyboardType(.URL)
                .autocapitalization(.none)
        }
    }

    private var addressInformationSection: some View {
        Section("Address Information") {
            TextField("Street Address (Optional)", text: $address)
                .focused($focusedField, equals: .address)

            TextField("City (Optional)", text: $city)
                .focused($focusedField, equals: .city)
                .autocapitalization(.words)

            TextField("State/Province (Optional)", text: $state)
                .focused($focusedField, equals: .state)
                .autocapitalization(.words)

            TextField("Postal Code (Optional)", text: $postalCode)
                .focused($focusedField, equals: .postalCode)

            TextField("Country (Optional)", text: $country)
                .focused($focusedField, equals: .country)
                .autocapitalization(.words)
        }
    }

    private var financialInformationSection: some View {
        Section("Financial Terms") {
            TextField("Credit Limit (Optional)", text: $creditLimit)
                .focused($focusedField, equals: .creditLimit)
                .keyboardType(.decimalPad)

            TextField("Payment Terms (Days, Optional)", text: $paymentTerms)
                .focused($focusedField, equals: .paymentTerms)
                .keyboardType(.numberPad)

            TextField("Discount % (Optional)", text: $discount)
                .focused($focusedField, equals: .discount)
                .keyboardType(.decimalPad)
        }
    }

    private var taxInformationSection: some View {
        Section("Tax Information") {
            TextField("Tax ID (Optional)", text: $taxId)
                .focused($focusedField, equals: .taxId)

            TextField("VAT Number (Optional)", text: $vatNumber)
                .focused($focusedField, equals: .vatNumber)
        }
    }

    private var additionalDetailsSection: some View {
        Section("Additional Details") {
            TextField("Notes (Optional)", text: $notes, axis: .vertical)
                .focused($focusedField, equals: .notes)
                .lineLimit(3...5)
        }
    }

    // MARK: - Helper Methods

    private func generatePartnerCode() {
        partnerCode = viewModel.generatePartnerCode(type: partnerType)
    }

    private func createPartner() {
        guard let userId = LocalAuthManager.shared.currentUserId,
              let accountId = selectedAccount?.id else {
            errorMessage = "User not authenticated or account not selected"
            showError = true
            return
        }

        isProcessing = true

        let partner = BusinessPartner(
            id: UUID().uuidString,
            userId: userId,
            partnerCode: partnerCode,
            name: name.trimmingCharacters(in: .whitespaces),
            type: partnerType,
            balance: 0.0,
            lastTransactionDate: Date(),
            accountId: accountId,
            firstName: firstName.nonEmptyOrNil,
            lastName: lastName.nonEmptyOrNil,
            email: email.nonEmptyOrNil,
            phone: phone.nonEmptyOrNil,
            mobile: mobile.nonEmptyOrNil,
            website: website.nonEmptyOrNil,
            address: address.nonEmptyOrNil,
            city: city.nonEmptyOrNil,
            state: state.nonEmptyOrNil,
            postalCode: postalCode.nonEmptyOrNil,
            country: country.nonEmptyOrNil,
            taxId: taxId.nonEmptyOrNil,
            vatNumber: vatNumber.nonEmptyOrNil,
            creditLimit: Double(creditLimit),
            paymentTerms: Int(paymentTerms),
            discount: Double(discount),
            isActive: isActive,
            notes: notes.nonEmptyOrNil,
            createdAt: Date(),
            updatedAt: Date()
        )

        Task {
            do {
                try await viewModel.createPartner(partner)
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

// MARK: - Account Picker Sheet

private struct AccountPickerSheet: View {
    let accounts: [ChartOfAccount]
    @Binding var selectedAccount: ChartOfAccount?
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""

    var filteredAccounts: [ChartOfAccount] {
        if searchText.isEmpty {
            return accounts.filter {
                $0.accountType.category == .asset || $0.accountType.category == .liability
            }
        }
        return accounts.filter {
            ($0.accountType.category == .asset || $0.accountType.category == .liability) &&
            ($0.accountName.localizedCaseInsensitiveContains(searchText) ||
             $0.accountCode.localizedCaseInsensitiveContains(searchText))
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

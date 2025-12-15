import SwiftUI

struct BusinessPartnerDetailView: View {
    let partner: BusinessPartner
    @ObservedObject var viewModel: BusinessPartnerViewModel
    @Environment(\.dismiss) var dismiss

    @State private var isEditing = false
    @State private var showDeleteAlert = false
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header Card
                partnerHeaderCard

                // Contact Information Card
                if hasContactInfo {
                    contactInformationCard
                }

                // Address Information Card
                if hasAddressInfo {
                    addressInformationCard
                }

                // Financial Information Card
                financialInformationCard

                // Tax Information Card
                if hasTaxInfo {
                    taxInformationCard
                }

                // Notes Card
                if let notes = partner.notes, !notes.isEmpty {
                    notesCard(notes: notes)
                }

                // Actions
                actionsSection
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(partner.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") {
                    isEditing = true
                }
            }
        }
        .sheet(isPresented: $isEditing) {
            EditBusinessPartnerView(partner: partner, viewModel: viewModel)
        }
        .alert("Delete Business Partner", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deletePartner()
            }
        } message: {
            Text("Are you sure you want to delete this business partner? This action cannot be undone.")
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }

    // MARK: - Computed Properties

    private var hasContactInfo: Bool {
        partner.firstName != nil || partner.lastName != nil ||
        partner.email != nil || partner.phone != nil ||
        partner.mobile != nil || partner.website != nil
    }

    private var hasAddressInfo: Bool {
        partner.address != nil || partner.city != nil ||
        partner.state != nil || partner.postalCode != nil ||
        partner.country != nil
    }

    private var hasTaxInfo: Bool {
        partner.taxId != nil || partner.vatNumber != nil
    }

    // MARK: - Header Card

    private var partnerHeaderCard: some View {
        VStack(spacing: 12) {
            Image(systemName: partner.type.icon)
                .font(.system(size: 60))
                .foregroundColor(AppConstants.Colors.brandPrimary)

            Text(partner.displayName)
                .font(.title2.bold())
                .multilineTextAlignment(.center)

            Text(partner.partnerCode)
                .font(.headline)
                .foregroundColor(.secondary)

            HStack(spacing: 8) {
                Text(partner.type.rawValue)
                    .font(.subheadline)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(AppConstants.Colors.brandPrimary.opacity(0.1))
                    .foregroundColor(AppConstants.Colors.brandPrimary)
                    .cornerRadius(8)

                if !partner.isActive {
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

    // MARK: - Contact Information Card

    private var contactInformationCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Contact Information", systemImage: "person.circle")
                .font(.headline)

            if let firstName = partner.firstName, !firstName.isEmpty {
                DetailRow(label: "First Name", value: firstName, icon: "person")
                Divider()
            }

            if let lastName = partner.lastName, !lastName.isEmpty {
                DetailRow(label: "Last Name", value: lastName, icon: "person")
                Divider()
            }

            if let email = partner.email, !email.isEmpty {
                HStack {
                    Label("Email", systemImage: "envelope")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Link(email, destination: URL(string: "mailto:\(email)")!)
                        .font(.body)
                }
                Divider()
            }

            if let phone = partner.phone, !phone.isEmpty {
                HStack {
                    Label("Phone", systemImage: "phone")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Link(phone, destination: URL(string: "tel:\(phone)")!)
                        .font(.body)
                }
                Divider()
            }

            if let mobile = partner.mobile, !mobile.isEmpty {
                HStack {
                    Label("Mobile", systemImage: "iphone")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Link(mobile, destination: URL(string: "tel:\(mobile)")!)
                        .font(.body)
                }
                Divider()
            }

            if let website = partner.website, !website.isEmpty {
                HStack {
                    Label("Website", systemImage: "globe")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    if let url = URL(string: website.hasPrefix("http") ? website : "https://\(website)") {
                        Link(website, destination: url)
                            .font(.body)
                            .lineLimit(1)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(AppConstants.CornerRadius.large)
        .shadow(radius: 2)
    }

    // MARK: - Address Information Card

    private var addressInformationCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Address Information", systemImage: "mappin.circle")
                .font(.headline)

            if let address = partner.formattedAddress {
                Text(address)
                    .font(.body)
                    .foregroundColor(.primary)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    if let address = partner.address {
                        Text(address)
                    }
                    if let city = partner.city {
                        Text(city)
                    }
                    if let state = partner.state {
                        Text(state)
                    }
                    if let postalCode = partner.postalCode {
                        Text(postalCode)
                    }
                    if let country = partner.country {
                        Text(country)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(AppConstants.CornerRadius.large)
        .shadow(radius: 2)
    }

    // MARK: - Financial Information Card

    private var financialInformationCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Financial Information", systemImage: "dollarsign.circle")
                .font(.headline)

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Current Balance")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Text(partner.balance, format: .currency(code: "USD"))
                        .font(.title2.bold())
                        .foregroundColor(partner.balance >= 0 ? .primary : .red)
                }

                Spacer()
            }

            if let creditLimit = partner.creditLimit {
                Divider()
                DetailRow(
                    label: "Credit Limit",
                    value: creditLimit.formatted(.currency(code: "USD")),
                    icon: "creditcard"
                )
            }

            if let paymentTerms = partner.paymentTerms {
                Divider()
                DetailRow(
                    label: "Payment Terms",
                    value: "\(paymentTerms) days",
                    icon: "calendar"
                )
            }

            if let discount = partner.discount {
                Divider()
                DetailRow(
                    label: "Discount",
                    value: "\(discount)%",
                    icon: "percent"
                )
            }

            Divider()

            HStack {
                Text("Last Transaction")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text(partner.lastTransactionDate, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(AppConstants.CornerRadius.large)
        .shadow(radius: 2)
    }

    // MARK: - Tax Information Card

    private var taxInformationCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Tax Information", systemImage: "doc.text")
                .font(.headline)

            if let taxId = partner.taxId, !taxId.isEmpty {
                DetailRow(label: "Tax ID", value: taxId, icon: "number")
                if partner.vatNumber != nil {
                    Divider()
                }
            }

            if let vatNumber = partner.vatNumber, !vatNumber.isEmpty {
                DetailRow(label: "VAT Number", value: vatNumber, icon: "number.circle")
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(AppConstants.CornerRadius.large)
        .shadow(radius: 2)
    }

    // MARK: - Notes Card

    private func notesCard(notes: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Notes", systemImage: "note.text")
                .font(.headline)

            Text(notes)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(AppConstants.CornerRadius.large)
        .shadow(radius: 2)
    }

    // MARK: - Actions Section

    private var actionsSection: some View {
        VStack(spacing: 12) {
            Button(action: { isEditing = true }) {
                Label("Edit Partner", systemImage: "pencil")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppConstants.Colors.brandPrimary)
                    .cornerRadius(AppConstants.CornerRadius.medium)
            }

            Button(action: { showDeleteAlert = true }) {
                Label("Delete Partner", systemImage: "trash")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(AppConstants.CornerRadius.medium)
            }
        }
    }

    // MARK: - Helper Methods

    private func deletePartner() {
        Task {
            do {
                try await viewModel.deletePartner(partner)
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

// MARK: - Edit Business Partner View

struct EditBusinessPartnerView: View {
    let partner: BusinessPartner
    @ObservedObject var viewModel: BusinessPartnerViewModel
    @StateObject private var accountVM = ChartOfAccountsViewModel()
    @Environment(\.dismiss) var dismiss

    @State private var name: String
    @State private var partnerType: BusinessPartner.PartnerType
    @State private var firstName: String
    @State private var lastName: String
    @State private var email: String
    @State private var phone: String
    @State private var mobile: String
    @State private var website: String
    @State private var address: String
    @State private var city: String
    @State private var state: String
    @State private var postalCode: String
    @State private var country: String
    @State private var taxId: String
    @State private var vatNumber: String
    @State private var creditLimit: String
    @State private var paymentTerms: String
    @State private var discount: String
    @State private var notes: String
    @State private var isActive: Bool
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

    init(partner: BusinessPartner, viewModel: BusinessPartnerViewModel) {
        self.partner = partner
        self.viewModel = viewModel
        _name = State(initialValue: partner.name)
        _partnerType = State(initialValue: partner.type)
        _firstName = State(initialValue: partner.firstName ?? "")
        _lastName = State(initialValue: partner.lastName ?? "")
        _email = State(initialValue: partner.email ?? "")
        _phone = State(initialValue: partner.phone ?? "")
        _mobile = State(initialValue: partner.mobile ?? "")
        _website = State(initialValue: partner.website ?? "")
        _address = State(initialValue: partner.address ?? "")
        _city = State(initialValue: partner.city ?? "")
        _state = State(initialValue: partner.state ?? "")
        _postalCode = State(initialValue: partner.postalCode ?? "")
        _country = State(initialValue: partner.country ?? "")
        _taxId = State(initialValue: partner.taxId ?? "")
        _vatNumber = State(initialValue: partner.vatNumber ?? "")
        _creditLimit = State(initialValue: partner.creditLimit?.description ?? "")
        _paymentTerms = State(initialValue: partner.paymentTerms?.description ?? "")
        _discount = State(initialValue: partner.discount?.description ?? "")
        _notes = State(initialValue: partner.notes ?? "")
        _isActive = State(initialValue: partner.isActive)
    }

    var hasChanges: Bool {
        name != partner.name ||
        partnerType != partner.type ||
        firstName != (partner.firstName ?? "") ||
        lastName != (partner.lastName ?? "") ||
        email != (partner.email ?? "") ||
        phone != (partner.phone ?? "") ||
        mobile != (partner.mobile ?? "") ||
        website != (partner.website ?? "") ||
        address != (partner.address ?? "") ||
        city != (partner.city ?? "") ||
        state != (partner.state ?? "") ||
        postalCode != (partner.postalCode ?? "") ||
        country != (partner.country ?? "") ||
        taxId != (partner.taxId ?? "") ||
        vatNumber != (partner.vatNumber ?? "") ||
        creditLimit != (partner.creditLimit?.description ?? "") ||
        paymentTerms != (partner.paymentTerms?.description ?? "") ||
        discount != (partner.discount?.description ?? "") ||
        notes != (partner.notes ?? "") ||
        isActive != partner.isActive ||
        (selectedAccount != nil && selectedAccount?.id != partner.accountId)
    }

    var canSubmit: Bool {
        hasChanges &&
        !name.trimmingCharacters(in: .whitespaces).isEmpty
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
                balanceSection
            }
            .navigationTitle("Edit Partner")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        updatePartner()
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
                if let account = accountVM.accounts.first(where: { $0.id == partner.accountId }) {
                    selectedAccount = account
                }
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

            TextField("Partner Code", text: .constant(partner.partnerCode))
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

    private var balanceSection: some View {
        Section {
            HStack {
                Text("Current Balance")
                    .foregroundColor(.secondary)
                Spacer()
                Text(partner.balance, format: .currency(code: "USD"))
                    .fontWeight(.bold)
            }
        } footer: {
            Text("Balance cannot be modified directly. Use transactions to adjust balances.")
                .font(.caption)
        }
    }

    // MARK: - Helper Methods

    private func updatePartner() {
        isProcessing = true

        var updatedPartner = partner
        updatedPartner.name = name.trimmingCharacters(in: .whitespaces)
        updatedPartner.type = partnerType
        updatedPartner.firstName = firstName.nonEmptyOrNil
        updatedPartner.lastName = lastName.nonEmptyOrNil
        updatedPartner.email = email.nonEmptyOrNil
        updatedPartner.phone = phone.nonEmptyOrNil
        updatedPartner.mobile = mobile.nonEmptyOrNil
        updatedPartner.website = website.nonEmptyOrNil
        updatedPartner.address = address.nonEmptyOrNil
        updatedPartner.city = city.nonEmptyOrNil
        updatedPartner.state = state.nonEmptyOrNil
        updatedPartner.postalCode = postalCode.nonEmptyOrNil
        updatedPartner.country = country.nonEmptyOrNil
        updatedPartner.taxId = taxId.nonEmptyOrNil
        updatedPartner.vatNumber = vatNumber.nonEmptyOrNil
        updatedPartner.creditLimit = Double(creditLimit)
        updatedPartner.paymentTerms = Int(paymentTerms)
        updatedPartner.discount = Double(discount)
        updatedPartner.notes = notes.nonEmptyOrNil
        updatedPartner.isActive = isActive
        if let accountId = selectedAccount?.id {
            updatedPartner.accountId = accountId
        }
        updatedPartner.updatedAt = Date()

        Task {
            do {
                try await viewModel.updatePartner(updatedPartner)
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
                            Spacer()
                            Text(account.accountType.rawValue)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search accounts")
            .navigationTitle("Select Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

# Reusable Components Guide

This guide demonstrates how to use the comprehensive reusable component library for maximum code reuse and consistency across the app.

## Table of Contents
1. [Form Components](#form-components)
2. [List Components](#list-components)
3. [Templates](#templates)
4. [Best Practices](#best-practices)

## Form Components

### GenericFormTemplate
A complete form template with built-in save/cancel/delete actions.

```swift
struct CreateAccountView: View {
    @State private var accountName = ""
    @State private var accountCode = ""
    @State private var accountType: AccountType = .asset
    @State private var isLoading = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        GenericFormTemplate(
            title: "Create Account",
            isLoading: isLoading,
            isSaveDisabled: accountName.isEmpty,
            saveAction: saveAccount,
            cancelAction: { dismiss() }
        ) {
            FormSection(title: "Basic Information", icon: "doc.text") {
                FormTextField(
                    label: "Account Name",
                    icon: "tag",
                    text: $accountName,
                    placeholder: "Enter account name"
                )
                
                FormTextField(
                    label: "Account Code",
                    icon: "number",
                    text: $accountCode,
                    placeholder: "1000"
                )
                
                FormPicker(
                    label: "Account Type",
                    icon: "list.bullet",
                    selection: $accountType,
                    options: AccountType.allCases
                )
            }
        }
    }
    
    private func saveAccount() {
        isLoading = true
        // Save logic here
    }
}
```

### Enhanced Form Fields

#### FormCurrencyField
```swift
FormCurrencyField(
    label: "Amount",
    icon: "dollarsign.circle",
    amount: $transactionAmount,
    currencySymbol: "SAR"
)
```

#### FormDatePicker
```swift
FormDatePicker(
    label: "Transaction Date",
    icon: "calendar",
    date: $transactionDate,
    displayedComponents: [.date]
)
```

#### FormToggle
```swift
FormToggle(
    label: "Is Active",
    icon: "checkmark.circle",
    isOn: $isActive,
    description: "Enable this account for transactions"
)
```

#### FormTextEditor
```swift
FormTextEditor(
    label: "Notes",
    icon: "note.text",
    text: $notes,
    placeholder: "Enter additional notes...",
    height: 120
)
```

## List Components

### GenericListRow
A flexible row component that adapts to any entity type.

```swift
struct AccountListView: View {
    let accounts: [Account]
    
    var body: some View {
        List(accounts) { account in
            NavigationLink(destination: AccountDetailView(account: account)) {
                GenericListRow(
                    item: account,
                    title: account.name,
                    subtitle: account.code,
                    trailing: account.balance.formatted(),
                    icon: "dollarsign.circle",
                    iconColor: .blue
                )
            }
        }
    }
}
```

### State Views

#### EmptyStateView
```swift
if accounts.isEmpty {
    EmptyStateView(
        title: "No Accounts",
        message: "Get started by creating your first account",
        icon: "doc.badge.plus",
        actionTitle: "Create Account",
        action: { showCreateAccount = true }
    )
}
```

#### LoadingStateView
```swift
if isLoading {
    LoadingStateView(message: "Loading accounts...")
}
```

#### ErrorStateView
```swift
if let error = viewModel.error {
    ErrorStateView(
        error: error,
        retryAction: viewModel.loadAccounts
    )
}
```

### Utility Components

#### StatusBadge
```swift
StatusBadge(status: "Open", color: .green)
StatusBadge(status: "Pending", color: .orange)
StatusBadge(status: "Closed", color: .gray)
```

#### AmountDisplay
```swift
AmountDisplay(
    amount: transaction.amount,
    currencySymbol: "SAR",
    isPositive: transaction.type == .credit
)
```

## Templates

### GenericDetailTemplate
A complete detail view template with built-in edit/delete actions.

```swift
struct AccountDetailView: View {
    let account: Account
    @State private var showEditSheet = false
    @State private var showDeleteAlert = false
    
    var body: some View {
        GenericDetailTemplate(
            title: account.name,
            subtitle: account.code,
            headerIcon: "dollarsign.circle",
            showEditButton: true,
            showDeleteButton: true,
            editAction: { showEditSheet = true },
            deleteAction: { showDeleteAlert = true }
        ) {
            DetailSection(title: "Account Information", icon: "info.circle") {
                DetailRow(
                    label: "Account Code",
                    value: account.code,
                    icon: "number"
                )
                DetailRow(
                    label: "Type",
                    value: account.type.rawValue,
                    icon: "tag"
                )
                DetailRow(
                    label: "Balance",
                    value: account.balance.formatted(),
                    icon: "dollarsign.circle"
                )
            }
            
            DetailSection(title: "Status", icon: "checkmark.circle") {
                DetailRow(
                    label: "Active",
                    value: account.isActive ? "Yes" : "No"
                )
            }
        }
        .sheet(isPresented: $showEditSheet) {
            EditAccountView(account: account)
        }
    }
}
```

## Best Practices

### 1. Consistent Component Usage
Always use reusable components instead of creating custom views:

✅ **Good:**
```swift
FormTextField(label: "Name", icon: "person", text: $name)
```

❌ **Avoid:**
```swift
VStack {
    Text("Name")
    TextField("Name", text: $name)
        .padding()
        .background(Color.gray)
}
```

### 2. Use FormSection for Grouping
Group related fields together:

```swift
FormSection(title: "Contact Information", icon: "person.circle") {
    FormTextField(label: "Email", icon: "envelope", text: $email)
    FormTextField(label: "Phone", icon: "phone", text: $phone)
}

FormSection(title: "Address", icon: "map") {
    FormTextField(label: "Street", icon: "house", text: $street)
    FormTextField(label: "City", icon: "building.2", text: $city)
}
```

### 3. Leverage State Views
Handle different states consistently:

```swift
var body: some View {
    Group {
        if isLoading {
            LoadingStateView(message: "Loading...")
        } else if let error = error {
            ErrorStateView(error: error, retryAction: retry)
        } else if items.isEmpty {
            EmptyStateView(
                title: "No Items",
                message: "No items to display",
                icon: "tray"
            )
        } else {
            ItemListView(items: items)
        }
    }
}
```

### 4. Component Composition
Build complex UIs by composing simple components:

```swift
GenericFormTemplate(title: "Create Transaction", ...) {
    FormSection(title: "Basic Details") {
        FormTextField(...)
        FormDatePicker(...)
    }
    
    FormSection(title: "Amount") {
        FormCurrencyField(...)
        FormPicker(...)
    }
    
    FormSection(title: "Additional Info") {
        FormToggle(...)
        FormTextEditor(...)
    }
}
```

### 5. Consistent Styling
Use AppConstants for consistent styling:

```swift
.padding(AppConstants.Spacing.medium)
.cornerRadius(AppConstants.CornerRadius.small)
.foregroundColor(AppConstants.Colors.brandPrimary)
```

## GRDB Integration

All components work seamlessly with GRDB. Example service integration:

```swift
@MainActor
class AccountViewModel: ObservableObject {
    @Published var accounts: [Account] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let dataController = GRDBDataControllerV2.shared
    
    func loadAccounts(userId: String) {
        isLoading = true
        error = nil
        
        Task {
            do {
                let accountsData = try dataController.dbQueue.read { db in
                    try Account
                        .filter(Column("userId") == userId)
                        .order(Column("name"))
                        .fetchAll(db)
                }
                accounts = accountsData
            } catch {
                self.error = error
            }
            isLoading = false
        }
    }
}
```

## Conclusion

By using these reusable components:
- ✅ Reduce code duplication by 60-80%
- ✅ Ensure consistent UI/UX across the app
- ✅ Simplify maintenance and updates
- ✅ Speed up development of new features
- ✅ Improve code readability and maintainability

For questions or improvements, refer to the component source files in `VistaVault/Shared/Components/`.

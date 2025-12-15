# VistaVault Development Guide

## Getting Started

### Prerequisites
- macOS 13.0 or later
- Xcode 15.0 or later
- CocoaPods or Swift Package Manager
- Firebase account

### Initial Setup
1. Clone the repository
2. Install dependencies
3. Configure Firebase
4. Run the app

## Component Development

### Creating a New Feature Module

When adding a new feature, follow this structure:

```
Features/
└── NewFeature/
    ├── Views/
    │   ├── NewFeatureListView.swift
    │   ├── NewFeatureDetailView.swift
    │   └── NewFeatureFormView.swift
    ├── ViewModels/
    │   └── NewFeatureViewModel.swift
    └── Models/
        └── NewFeature.swift
```

### Example: Adding a New Feature

#### 1. Create the Model
```swift
// Features/NewFeature/Models/NewFeature.swift
import Foundation
import FirebaseFirestore

struct NewFeature: Identifiable, Codable {
    @DocumentID var id: String?
    let name: String
    let userId: String
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case userId = "user_id"
        case createdAt = "created_at"
    }
}
```

#### 2. Create the ViewModel
```swift
// Features/NewFeature/ViewModels/NewFeatureViewModel.swift
import Foundation
import FirebaseFirestore

class NewFeatureViewModel: ObservableObject {
    @Published var items: [NewFeature] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let db = FirebaseManager.shared.firestore
    
    func fetchItems(userId: String) {
        isLoading = true
        
        db.collection("new_features")
            .whereField("user_id", isEqualTo: userId)
            .getDocuments { [weak self] snapshot, error in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    
                    if let error = error {
                        self?.errorMessage = error.localizedDescription
                        return
                    }
                    
                    self?.items = snapshot?.documents.compactMap { doc in
                        try? doc.data(as: NewFeature.self)
                    } ?? []
                }
            }
    }
}
```

#### 3. Create the List View
```swift
// Features/NewFeature/Views/NewFeatureListView.swift
import SwiftUI

struct NewFeatureListView: View {
    @StateObject private var viewModel = NewFeatureViewModel()
    
    var body: some View {
        BaseListTemplate(
            items: viewModel.items,
            isLoading: viewModel.isLoading,
            emptyStateTitle: "No Items",
            emptyStateIcon: "folder"
        ) { item in
            NewFeatureRow(item: item)
        }
        .navigationTitle("New Feature")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { /* Add new */ }) {
                    Image(systemName: "plus")
                }
            }
        }
        .onAppear {
            if let userId = FirebaseManager.shared.auth.currentUser?.uid {
                viewModel.fetchItems(userId: userId)
            }
        }
    }
}
```

## Using AppConstants

### Always Use Constants for Styling

❌ **Don't do this:**
```swift
.padding(16)
.cornerRadius(12)
.foregroundColor(.blue)
```

✅ **Do this:**
```swift
.padding(AppConstants.Spacing.medium)
.cornerRadius(AppConstants.CornerRadius.medium)
.foregroundColor(AppConstants.Colors.brandPrimary)
```

### Available Constants

#### Colors
```swift
AppConstants.Colors.brandPrimary        // Color.indigo
AppConstants.Colors.brandSecondary      // Custom brand color
AppConstants.Colors.creditColor         // Color.green
AppConstants.Colors.debitColor          // Color.red
AppConstants.Colors.creditGradient      // Green gradient
AppConstants.Colors.debitGradient       // Red gradient
AppConstants.Colors.brandGradient       // Brand gradient
```

#### Spacing
```swift
AppConstants.Spacing.small         // 8
AppConstants.Spacing.medium        // 16
AppConstants.Spacing.large         // 24
AppConstants.Spacing.extraLarge    // 32
```

#### Corner Radius
```swift
AppConstants.CornerRadius.small         // 8
AppConstants.CornerRadius.medium        // 12
AppConstants.CornerRadius.large         // 16
AppConstants.CornerRadius.extraLarge    // 20
```

#### Icon Sizes
```swift
AppConstants.IconSize.small         // 20
AppConstants.IconSize.medium        // 28
AppConstants.IconSize.large         // 40
AppConstants.IconSize.extraLarge    // 64
```

## Using Unified Components

### TransactionRow

Display any payment transaction:

```swift
ForEach(payments) { payment in
    TransactionRow(
        payment: payment,
        customerName: getCustomerName(for: payment.customerId)
    )
}
```

### SectionCard

Group related content:

```swift
SectionCard(title: "Overview", systemImage: "chart.bar") {
    VStack {
        Text("Content here")
        // More content...
    }
}
```

### MetricView

Display financial metrics:

```swift
MetricView(
    title: "Total Sales",
    value: "$1,234.56",
    icon: "dollarsign.circle",
    gradient: AppConstants.Colors.creditGradient,
    color: AppConstants.Colors.creditColor
)
```

### BaseListTemplate

Create consistent list views:

```swift
BaseListTemplate(
    items: items,
    isLoading: isLoading,
    emptyStateTitle: "No Items",
    emptyStateIcon: "folder"
) { item in
    ItemRow(item: item)
}
```

### BaseFormTemplate

Create standardized forms:

```swift
BaseFormTemplate(
    title: "New Item",
    isLoading: isLoading,
    canSave: formIsValid,
    onSave: saveItem,
    onCancel: { dismiss() }
) {
    FormFieldSection(title: "Details", icon: "info.circle") {
        TextField("Name", text: $name)
    }
}
```

## Accounting Services

### ChartOfAccountsService

```swift
// Validate account structure
let isValid = ChartOfAccountsService.shared.validateAccountStructure(
    type: .asset,
    code: "1001"
)

// Create journal entry from payment
let journalEntry = ChartOfAccountsService.shared.createJournalEntryFromPayment(
    payment,
    debitAccount: "1001",
    creditAccount: "1002"
)
```

### AccountingCalculations

```swift
// Calculate gross profit
let profit = AccountingCalculations.grossProfit(
    revenue: 10000,
    cogs: 6000
)

// Calculate profit margin
let margin = AccountingCalculations.grossProfitMargin(
    revenue: 10000,
    cogs: 6000
)

// Format currency
let formatted = AccountingCalculations.formatCurrency(1234.56)
// Output: "SAR 1,234.56"
```

## Error Handling

### Using AppError

```swift
func saveData() async throws {
    guard isValid else {
        throw AppError.validationFailed("Invalid data format")
    }
    
    guard amount > 0 else {
        throw AppError.invalidAmount
    }
    
    do {
        // Save operation
    } catch {
        throw AppError.saveFailed
    }
}
```

### Handling Errors in Views

```swift
@State private var errorMessage: String?
@State private var showError = false

// In view body
.alert("Error", isPresented: $showError) {
    Button("OK", role: .cancel) { }
} message: {
    Text(errorMessage ?? "An error occurred")
}

// When calling async function
Task {
    do {
        try await saveData()
    } catch let error as AppError {
        errorMessage = error.errorDescription
        showError = true
    }
}
```

## Date Utilities

### Using DateExtensions

```swift
// Get date ranges
let startOfMonth = Date().startOfMonth
let endOfMonth = Date().endOfMonth
let startOfYear = Date().startOfYear

// Check fiscal year
let isCurrentFiscal = date.isInCurrentFiscalYear(startMonth: 1)

// Format accounting period
let period = Date().accountingPeriod(quarterly: true)
// Output: "Q4 2024"
```

## Firebase Integration

### Adding a New Collection

1. **Define the model:**
```swift
struct MyModel: Codable, Identifiable {
    @DocumentID var id: String?
    let name: String
    let userId: String
}
```

2. **Create CRUD operations:**
```swift
class MyViewModel: ObservableObject {
    private let db = FirebaseManager.shared.firestore
    private let collection = "my_collection"
    
    func create(_ item: MyModel) async throws {
        try db.collection(collection).document().setData(from: item)
    }
    
    func fetch(userId: String) async throws -> [MyModel] {
        let snapshot = try await db.collection(collection)
            .whereField("userId", isEqualTo: userId)
            .getDocuments()
        
        return snapshot.documents.compactMap { doc in
            try? doc.data(as: MyModel.self)
        }
    }
}
```

## Navigation

### Using NavigationCoordinator

```swift
@EnvironmentObject var coordinator: NavigationCoordinator

// Switch tabs
coordinator.navigate(to: .payments)

// Push view
coordinator.push(NavigationDestination.customerDetail(customer))

// Pop view
coordinator.pop()

// Pop to root
coordinator.popToRoot()
```

## Testing

### Unit Testing ViewModels

```swift
import XCTest
@testable import VistaVault

class MyViewModelTests: XCTestCase {
    var sut: MyViewModel!
    
    override func setUp() {
        super.setUp()
        sut = MyViewModel()
    }
    
    func testFetchItems() async throws {
        // Given
        let userId = "test-user-id"
        
        // When
        try await sut.fetchItems(userId: userId)
        
        // Then
        XCTAssertFalse(sut.items.isEmpty)
    }
}
```

### Testing Accounting Calculations

```swift
func testGrossProfitCalculation() {
    // Given
    let revenue = 10000.0
    let cogs = 6000.0
    
    // When
    let profit = AccountingCalculations.grossProfit(revenue: revenue, cogs: cogs)
    
    // Then
    XCTAssertEqual(profit, 4000.0)
}

func testJournalEntryBalancing() {
    // Given
    let lineItems = [
        JournalLineItem(id: "1", accountId: "1001", accountName: "Cash", 
                       type: .debit, amount: 1000, memo: nil),
        JournalLineItem(id: "2", accountId: "4001", accountName: "Revenue", 
                       type: .credit, amount: 1000, memo: nil)
    ]
    
    // When
    let isBalanced = AccountingCalculations.isBalanced(lineItems: lineItems)
    
    // Then
    XCTAssertTrue(isBalanced)
}
```

## Performance Optimization

### LazyVStack for Long Lists

```swift
ScrollView {
    LazyVStack(spacing: AppConstants.Spacing.small) {
        ForEach(items) { item in
            ItemRow(item: item)
        }
    }
}
```

### Debouncing Search

```swift
@State private var searchText = ""

var body: some View {
    List { /* ... */ }
        .searchable(text: $searchText)
        .onChange(of: searchText) { newValue in
            NSObject.cancelPreviousPerformRequests(
                withTarget: self,
                selector: #selector(performSearch),
                object: nil
            )
            perform(#selector(performSearch), with: nil, afterDelay: 0.5)
        }
}
```

## Common Patterns

### Loading State

```swift
@State private var isLoading = false

var body: some View {
    ZStack {
        content
        
        if isLoading {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black.opacity(0.2))
        }
    }
}
```

### Empty State

```swift
if items.isEmpty {
    ContentUnavailableView(
        "No Items",
        systemImage: "folder",
        description: Text("Add items to get started")
    )
}
```

### Pull to Refresh

```swift
List(items) { item in
    ItemRow(item: item)
}
.refreshable {
    await viewModel.refresh()
}
```

## Debugging Tips

### Print Statements
```swift
print("DEBUG: \(functionName) - \(variable)")
```

### Breakpoint Logging
Use `po` command in debugger:
```
po viewModel.items
po error.localizedDescription
```

### Network Debugging
Enable Firebase debugging:
```swift
// In AppDelegate
FirebaseConfiguration.shared.setLoggerLevel(.debug)
```

## Code Review Checklist

- [ ] Uses AppConstants for all styling
- [ ] Follows MVVM pattern
- [ ] Includes error handling
- [ ] Has appropriate access control
- [ ] Includes documentation comments
- [ ] Follows Swift naming conventions
- [ ] No force unwrapping (!)
- [ ] Uses guard for early returns
- [ ] Async/await for async operations
- [ ] No hardcoded strings (use localization when needed)

## Resources

- [Swift Style Guide](https://swift.org/documentation/api-design-guidelines/)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui/)
- [Firebase Documentation](https://firebase.google.com/docs/ios/setup)
- [GAAP Principles](https://www.fasb.org/)

---

Happy coding! 🚀

# VistaVault - iOS Finance & Accounting App

A modern iOS accounting application built with SwiftUI, following standard accounting principles and best practices.

## Features

### 📊 Core Accounting Modules

#### ✅ Chart of Accounts (Complete)
- **Standard Account Structure**: Follows GAAP/IFRS numbering (1000-6999)
- **Six Account Categories**: Assets, Liabilities, Equity, Revenue, Expenses, COGS
- **Account Hierarchy**: Parent-child account relationships
- **Balance Tracking**: Real-time debit/credit balance updates
- **Default Initialization**: Pre-configured standard accounts
- **Custom Accounts**: Create accounts specific to your business

#### ✅ Business Partners (Complete)
- **Unified Management**: Combined customer and vendor management
- **Multiple Types**: Customer, Vendor, or Both
- **Comprehensive Data**: Contact info, addresses, tax details, payment terms
- **Auto-numbering**: Automatic partner code generation (CUS####, VEN####, BP####)
- **Credit Management**: Credit limits and balance tracking
- **Search & Filter**: Find partners by type, name, or status

#### ✅ Purchase Management (Backend Complete)
- **Purchase Orders**: Create and manage vendor purchases
- **Status Tracking**: Draft, Ordered, Received, Partially Paid, Paid, Cancelled
- **Multi-line Items**: Support for multiple items per purchase
- **Automatic Calculations**: Tax, discount, and total calculations
- **Payment Tracking**: Track paid amounts and outstanding balances
- **Vendor Integration**: Link purchases to business partners

#### ✅ Sales Management (Backend Complete)
- **Sales & Invoices**: Create customer sales and invoices
- **Status Tracking**: Draft, Pending, Confirmed, Shipped, Partially Paid, Paid, Cancelled
- **Multi-line Items**: Support for multiple items per sale
- **Automatic Calculations**: Tax, discount, and total calculations
- **Payment & Shipping**: Track payments and shipping status
- **Customer Integration**: Link sales to business partners

#### ✅ Payment Processing (Complete)
- **Transaction Management**: Record credit and debit transactions
- **Customer Linking**: Associate payments with customers
- **Transaction History**: Complete payment history with filtering
- **Balance Tracking**: Real-time customer balance updates
- **Transaction Numbers**: Auto-generated transaction references

#### ✅ Invoice Management (Complete)
- **Create Invoices**: Multi-line item invoices
- **Invoice Tracking**: Status and payment tracking
- **Customer Integration**: Link invoices to customers
- **Line Items**: Detailed item breakdown with quantities and prices

#### ✅ Inventory Management (Complete)
- **Product Tracking**: Monitor products and services
- **Unit Management**: Multiple units of measure support
- **Price Management**: Track purchase and sales prices
- **Quantity Tracking**: Real-time stock quantities
- **Product Codes**: Custom product identification

### 🎨 User Interface
- **Modern SwiftUI Design**: Clean, professional interface
- **Consistent Styling**: AppConstants for unified look and feel
- **Reusable Components**: FormComponents, ListRowComponents for consistency
- **Tab Navigation**: Accounts, Transactions, More, Profile
- **Search & Filter**: Real-time search across all modules
- **Responsive Forms**: Validated input fields with error handling
- **List Views**: Efficient list displays with detail views

### 🏗️ Architecture
- **MVVM Pattern**: ViewModels manage business logic and state
- **Feature Modules**: 9 complete feature modules with separation of concerns
- **Service Layer**: 7 specialized services (942 LOC)
- **Reusable Components**: FormComponents, ListRowComponents, Templates
- **Type-Safe Navigation**: NavigationCoordinator for centralized routing
- **Protocol-Oriented**: ViewModelProtocols for consistent interfaces
- **Comprehensive Error Handling**: AppError with localized messages
- **Async/Await**: Modern Swift concurrency throughout

## Project Structure

```
VistaVault/
├── APP/                          # Application entry
│   └── VistaVaultApp.swift      
│
├── Core/                         # Core business logic (942 LOC services)
│   ├── Models/                   # Shared data models
│   │   ├── JournalEntry.swift
│   │   └── AppError.swift
│   ├── Services/                 # Business services (7 services)
│   │   ├── AccountService.swift
│   │   ├── AccountingCalculations.swift
│   │   ├── BusinessPartnerService.swift
│   │   ├── ChartOfAccountsService.swift
│   │   ├── NavigationCoordinator.swift
│   │   ├── PurchaseService.swift
│   │   └── SaleService.swift
│   ├── Protocols/                # Common protocols
│   │   └── ViewModelProtocols.swift
│   └── Templates/                # Reusable view templates
│       ├── BaseListTemplate.swift
│       └── BaseFormTemplate.swift
│
├── Features/                     # Feature modules (1,452 LOC ViewModels)
│   ├── Authentication/           # User authentication
│   ├── BusinessPartners/         # ✅ Customer & vendor management
│   ├── ChartOfAccounts/          # ✅ Chart of accounts
│   ├── CompanyProfile/           # Company profile management
│   ├── Inventory/                # ✅ Inventory tracking
│   ├── Invoices/                 # ✅ Invoice management
│   ├── Payments/                 # ✅ Payment processing
│   ├── Purchases/                # ✅ Purchase orders (backend)
│   └── Sales/                    # ✅ Sales management (backend)
│
├── Shared/                       # Shared UI components
│   ├── Components/
│   │   ├── Common/               # Reusable UI components
│   │   ├── Forms/                # FormComponents
│   │   └── Lists/                # ListRowComponents
│   └── Constants/
│       └── AppConstants.swift    # Centralized styling
│
├── Utilities/                    # Helper utilities
│   ├── Formatters/
│   │   └── CurrencyFormatter.swift
│   └── Extensions/
│       └── DateExtensions.swift
│
└── GeneralViews/                 # Main app views
    ├── RootView.swift
    ├── HomeView.swift
    └── FirebaseManager.swift
```

## Requirements

- iOS 16.0+
- Xcode 15.0+
- Swift 5.9+
- Firebase account for backend services

## Installation

1. Clone the repository:
```bash
git clone https://github.com/asaddd1413/Finance.git
cd Finance
```

2. Install development tools (optional but recommended):
```bash
# Using Homebrew on macOS
brew install swiftlint swiftformat
```

3. Install dependencies (if using CocoaPods):
```bash
pod install
```

4. Open the project:
```bash
open VistaVault.xcodeproj
```

5. Configure Firebase:
   - Add your `GoogleService-Info.plist` to the project
   - Ensure Firebase is configured in the project

6. Build and run the project

## Usage

### First Time Setup
1. Launch the app
2. Create an account or sign in
3. Complete your company profile
4. Start managing your finances!

### Creating Transactions
1. Navigate to the Payments tab
2. Tap "New Payment"
3. Select a customer
4. Choose transaction type (Credit/Debit)
5. Enter amount and notes
6. Save the transaction

### Managing Customers
1. Go to Menu → Customers
2. Tap "+" to add new customer
3. Fill in customer details
4. Save and start tracking their transactions

### Viewing Reports
1. Navigate to Menu → Reports
2. Set date range filters
3. Filter by transaction type or customer
4. Generate report
5. View detailed transaction list

## Accounting Structure

### Chart of Accounts
- **1000-1999**: Assets (Cash, Accounts Receivable, Inventory)
- **2000-2999**: Liabilities (Accounts Payable, Loans)
- **3000-3999**: Equity (Owner's Capital, Retained Earnings)
- **4000-4999**: Revenue (Sales, Service Revenue)
- **5000-5999**: Expenses (Operating Expenses, Salaries)
- **6000-6999**: Cost of Goods Sold

### Double-Entry Bookkeeping
Every transaction creates balanced journal entries:
- Total Debits = Total Credits
- Maintains accounting equation: Assets = Liabilities + Equity

## Key Components

### AppConstants
Centralized styling constants:
- Colors (brand, credit/debit)
- Spacing (8, 16, 24, 32)
- Corner radius (8, 12, 16, 20)
- Icon sizes (20, 28, 40, 64)

### Unified Components
- **TransactionRow**: Display all transactions consistently
- **SectionCard**: Container for grouped content
- **MetricView**: Display financial metrics
- **BaseListTemplate**: Generic list views
- **BaseFormTemplate**: Standardized forms

### Services
- **ChartOfAccountsService**: Manage account structure
- **AccountingCalculations**: Financial formulas and calculations
- **NavigationCoordinator**: Centralized navigation
- **CurrencyFormatter**: Format currency displays

## Development Guidelines

### Code Style
- Follow Swift API Design Guidelines
- Use meaningful variable and function names
- Add comments for complex business logic
- Keep functions focused and single-purpose
- Code is automatically formatted with SwiftFormat
- Code is linted with SwiftLint

### Linting and Formatting

The project uses SwiftLint and SwiftFormat to maintain code quality and consistency.

#### SwiftLint
```bash
# Run SwiftLint
swiftlint lint

# Auto-fix issues where possible
swiftlint lint --fix
```

#### SwiftFormat
```bash
# Format all Swift files
swiftformat VistaVault VistaVaultTests

# Check formatting without modifying files
swiftformat --lint VistaVault VistaVaultTests
```

Configuration files:
- `.swiftlint.yml` - SwiftLint rules and settings
- `.swiftformat` - SwiftFormat rules and preferences

### Component Usage
```swift
// Always use AppConstants
.padding(AppConstants.Spacing.medium)
.cornerRadius(AppConstants.CornerRadius.large)
.foregroundColor(AppConstants.Colors.brandPrimary)

// Use unified components
TransactionRow(payment: payment, customerName: name)
SectionCard(title: "Overview", systemImage: "chart.bar") {
    // Content
}
```

### Error Handling
```swift
do {
    try await someOperation()
} catch {
    // Use AppError for consistent error handling
    throw AppError.saveFailed
}
```

## Testing

### Test Infrastructure
The app includes comprehensive testing with **780+ lines of test code** covering critical business logic.

#### Test Suites

| Test Suite | LOC | Coverage |
|------------|-----|----------|
| PurchaseServiceTests | 181 | Complete CRUD and calculation tests |
| SaleServiceTests | 244 | Service layer with all scenarios |
| PurchaseViewModelTests | 177 | ViewModel state and filtering |
| AccountingCalculationsTests | 178 | Financial calculations |

### Run Tests
```bash
# Run all tests
xcodebuild test -scheme VistaVault -destination 'platform=iOS Simulator,name=iPhone 15'

# Run specific test suite
xcodebuild test -scheme VistaVault -only-testing:VistaVaultTests/PurchaseServiceTests

# Run single test
xcodebuild test -scheme VistaVault -only-testing:VistaVaultTests/PurchaseServiceTests/testCalculateTotals
```

### Test Coverage
- ✅ **Service Layer**: 100% coverage on tested modules
- ✅ **ViewModel Layer**: Filtering, search, computed properties
- ✅ **Model Calculations**: Tax, discount, totals validated
- ✅ **Accounting Logic**: Profit margins, equation verification
- ⚠️ **Integration Tests**: Recommended for complete workflows
- ⚠️ **UI Tests**: Recommended for critical user flows

See [TESTING_GUIDE.md](TESTING_GUIDE.md) for comprehensive testing documentation.

## Architecture Documentation

See [ARCHITECTURE.md](ARCHITECTURE.md) for detailed architecture documentation including:
- Detailed project structure
- Design patterns and principles
- Data models and relationships
- Best practices and conventions

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Contribution Guidelines
- Follow existing code style
- Run SwiftFormat before committing: `swiftformat VistaVault VistaVaultTests`
- Ensure SwiftLint passes: `swiftlint lint`
- Use AppConstants for all styling
- Add tests for new features
- Update documentation as needed
- Ensure all tests pass before submitting PR

## Implementation Status

### ✅ Completed Modules (Backend + UI)
- [x] **Business Partners**: Complete with views and CRUD operations
- [x] **Chart of Accounts**: Full accounting structure with views
- [x] **Inventory Management**: Complete with detail views and units
- [x] **Payment Processing**: Transaction management with history
- [x] **Invoice Management**: Create, edit, and track invoices
- [x] **Authentication**: User login and registration
- [x] **Company Profile**: Profile management and editing

### ✅ Backend Complete (UI Pending)
- [x] **Purchase Orders**: Full service and ViewModel (192 LOC service, 178 LOC VM)
- [x] **Sales Management**: Complete backend implementation (204 LOC service, 195 LOC VM)

### 🔄 In Progress
- [ ] **Purchase UI**: Views for purchase order workflow
- [ ] **Sales UI**: Views for sales and invoice workflow
- [ ] **Journal Entry Automation**: Auto-create entries from transactions

### 📋 Roadmap

#### Version 2.1 (Next Release)
- [ ] Purchase Order UI views
- [ ] Sales/Invoice UI views
- [ ] Journal Entry automation
- [ ] Financial Statements (Balance Sheet, P&L)
- [ ] PDF Export for invoices
- [ ] Advanced reporting with filters

#### Version 2.2
- [ ] Bank reconciliation
- [ ] Recurring transactions
- [ ] Budget management
- [ ] Multi-currency support
- [ ] Audit trail

#### Version 3.0
- [ ] Multi-user support
- [ ] Role-based permissions
- [ ] Advanced analytics dashboard
- [ ] API for third-party integrations
- [ ] Mobile receipt scanning

## License

This project is proprietary software. All rights reserved.

## Support

For support, email support@vistavault.com or open an issue in the GitHub repository.

## Acknowledgments

- Firebase for backend services
- SwiftUI for modern iOS development
- The accounting community for best practices

## Version History

### v2.0.0 (Current - December 2024)
**Major Release: Professional Accounting Features**

#### New Modules
- ✅ Business Partner management (unified customers/vendors)
- ✅ Complete Chart of Accounts with standard structure
- ✅ Purchase Order management (backend complete)
- ✅ Sales management (backend complete)
- ✅ Enhanced inventory integration

#### Infrastructure Improvements
- ✅ 7 specialized services (942 LOC)
- ✅ MVVM architecture across all modules (1,452 LOC ViewModels)
- ✅ Reusable UI components (Forms, Lists)
- ✅ Comprehensive testing infrastructure (780 LOC tests)
- ✅ Protocol-oriented design
- ✅ Modern async/await throughout

#### Documentation
- ✅ 8 comprehensive documentation files (2,800+ LOC)
- ✅ Testing guide with examples
- ✅ CRUD implementation guide
- ✅ Architecture documentation
- ✅ QA review analysis

#### Statistics
- **Production Code**: ~3,500 LOC
- **Test Code**: 780 LOC
- **Documentation**: ~2,800 LOC
- **Total**: ~7,100 LOC
- **Feature Modules**: 9 complete modules
- **Test Coverage**: 100% on tested modules

### v1.0.0 (Initial Release)
- Initial release with core accounting features
- Customer and payment management
- Invoice creation
- Transaction reporting
- Basic chart of accounts
- Firebase integration

---

Built with ❤️ using SwiftUI

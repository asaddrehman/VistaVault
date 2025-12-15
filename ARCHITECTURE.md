# VistaVault Architecture Documentation

## Overview
VistaVault is a SwiftUI-based iOS accounting and finance management application that follows standard accounting principles and modern iOS development best practices.

## Project Structure

```
VistaVault/
├── APP/                          # App entry point
│   └── VistaVaultApp.swift      # Main app file
│
├── Core/                         # Core business logic and utilities
│   ├── Models/                   # Shared data models
│   │   ├── JournalEntry.swift   # Double-entry accounting model
│   │   └── AppError.swift       # Standardized error handling
│   │
│   ├── Services/                 # Business logic services
│   │   ├── ChartOfAccountsService.swift      # Standard account structure
│   │   ├── AccountingCalculations.swift      # Financial calculations
│   │   └── NavigationCoordinator.swift       # Navigation management
│   │
│   ├── Protocols/                # Common protocols
│   │   └── ViewModelProtocols.swift          # ViewModel interfaces
│   │
│   └── Templates/                # Reusable view templates
│       ├── BaseListTemplate.swift            # Standard list views
│       └── BaseFormTemplate.swift            # Standard forms
│
├── Features/                     # Feature modules
│   ├── Authentication/           # User authentication
│   ├── CompanyProfile/          # Company/profile management
│   ├── Customers/               # Customer management
│   ├── Inventory/               # Inventory tracking
│   ├── Invoices/                # Invoice management
│   ├── Payments/                # Payment processing
│   └── Ledgers/                 # Ledger/accounts management
│
├── Shared/                      # Shared UI components
│   ├── Components/
│   │   └── Common/              # Reusable UI components
│   │       ├── TransactionRow.swift         # Unified transaction display
│   │       ├── SectionCard.swift           # Card container
│   │       ├── MetricView.swift            # Metric display
│   │       └── ActionButton.swift          # Standard buttons
│   │
│   └── Constants/
│       └── AppConstants.swift               # App-wide constants
│
├── Utilities/                   # Helper utilities
│   ├── Formatters/
│   │   └── CurrencyFormatter.swift         # Currency formatting
│   │
│   └── Extensions/
│       └── DateExtensions.swift            # Date utilities
│
├── GeneralViews/               # Main app views
│   ├── RootView.swift          # Root coordinator
│   ├── HomeView.swift          # Main tab view
│   └── FirebaseManager.swift   # Firebase integration
│
└── Reports/                    # Reporting features
    └── ReportsView.swift       # Transaction reports
```

## Architecture Principles

### 1. MVVM Pattern
- **Views**: SwiftUI views for UI
- **ViewModels**: ObservableObject classes managing state
- **Models**: Codable structs for data

### 2. Standard Accounting Structure

#### Chart of Accounts
The app follows standard accounting account numbering:
- **1000-1999**: Assets (Debit balance)
- **2000-2999**: Liabilities (Credit balance)
- **3000-3999**: Equity (Credit balance)
- **4000-4999**: Revenue (Credit balance)
- **5000-5999**: Expenses (Debit balance)
- **6000-6999**: Cost of Goods Sold (Debit balance)

#### Double-Entry Accounting
All transactions follow double-entry bookkeeping:
- Every transaction has equal debits and credits
- Journal entries maintain the accounting equation: **Assets = Liabilities + Equity**

### 3. Component Standardization

#### AppConstants
Centralized constants for:
- Colors (brand, credit/debit, gradients)
- Spacing (small, medium, large, extraLarge)
- Corner radius (small, medium, large, extraLarge)
- Icon sizes (small, medium, large, extraLarge)

#### Unified Components
- **TransactionRow**: Single component for all transaction displays
- **SectionCard**: Consistent card layout
- **MetricView**: Standardized metric display
- **BaseListTemplate**: Generic list view template
- **BaseFormTemplate**: Standardized form layout

### 4. Services

#### ChartOfAccountsService
- Manages standard account structure
- Validates account types
- Creates journal entries from transactions

#### AccountingCalculations
- Financial calculations (gross profit, net profit, margins)
- Account balance calculations
- Accounting equation verification
- Currency formatting

#### NavigationCoordinator
- Centralized navigation management
- Type-safe navigation destinations
- Tab and navigation path management

### 5. Error Handling

#### AppError
Comprehensive error types:
- Authentication errors
- Data errors
- Accounting errors (unbalanced entries, invalid amounts)
- Network errors
- Validation errors

Each error provides:
- Localized description
- Recovery suggestions

## Data Models

### Core Entities

1. **Customer**: Customer information and account tracking
2. **Payment**: Transaction records (credit/debit)
3. **Invoice**: Sales invoices with line items
4. **Ledger**: Chart of accounts entries
5. **InventoryItem**: Product/service inventory
6. **JournalEntry**: Double-entry accounting records

### Relationships
- Customers have many Payments
- Customers have many Invoices
- Invoices contain InvoiceItems
- Payments link to Customers via customerId
- Ledgers form the Chart of Accounts

## Features

### 1. Dashboard (Ledgers)
- View all accounts in chart of accounts
- Quick access to account details
- Balance overview

### 2. Menu
- Navigation to Customers
- Navigation to Inventory
- Navigation to Reports

### 3. Payments
- Create new payments (credit/debit)
- View transaction history
- Customer payment tracking
- Balance overview

### 4. Profile
- Company profile management
- User authentication
- Settings and preferences

### 5. Reports
- Transaction filtering by:
  - Date range
  - Transaction type (credit/debit)
  - Customer
- Export capabilities

## Best Practices

### Code Organization
1. Group related files in feature folders
2. Use Core/ for shared business logic
3. Keep view code in Views/, logic in ViewModels/
4. Use Shared/ for reusable UI components

### Naming Conventions
- Views: `{Feature}View` (e.g., `CustomerListView`)
- ViewModels: `{Feature}ViewModel` (e.g., `CustomerViewModel`)
- Models: Descriptive nouns (e.g., `Customer`, `Payment`)
- Services: `{Purpose}Service` (e.g., `ChartOfAccountsService`)

### UI Consistency
- Always use `AppConstants` for styling values
- Use unified components (TransactionRow, SectionCard, MetricView)
- Follow iOS Human Interface Guidelines
- Maintain consistent spacing and corner radius

### Accounting Integrity
- Always validate journal entries are balanced
- Follow standard chart of accounts numbering
- Maintain double-entry bookkeeping principles
- Use AccountingCalculations for financial formulas

## Testing Recommendations

1. **Unit Tests**: Test ViewModels and Services
2. **Integration Tests**: Test Firebase integration
3. **UI Tests**: Test critical user flows
4. **Accounting Tests**: Verify double-entry balancing

## Future Enhancements

### Recommended Additions
1. **Financial Statements**
   - Balance Sheet
   - Income Statement (P&L)
   - Cash Flow Statement
   
2. **Advanced Reporting**
   - Custom report builder
   - PDF export with company branding
   - Email/share reports

3. **Multi-currency Support**
   - Currency conversion
   - Exchange rate tracking

4. **Audit Trail**
   - Transaction history
   - User activity logging
   - Change tracking

5. **Budget Management**
   - Budget creation
   - Budget vs. actual reporting
   - Variance analysis

## Security Considerations

1. **Authentication**: Firebase Authentication
2. **Data Privacy**: User data isolation via userId
3. **Validation**: Input validation on all forms
4. **Error Handling**: Graceful error handling with user-friendly messages

## Dependencies

- SwiftUI: UI framework
- Firebase Auth: User authentication
- Firebase Firestore: Database
- Foundation: Core utilities

## Support

For questions or issues, refer to:
- iOS Human Interface Guidelines
- SwiftUI Documentation
- Firebase Documentation
- Standard accounting principles (GAAP/IFRS)

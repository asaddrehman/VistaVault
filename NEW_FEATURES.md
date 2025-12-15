# New Features - VistaVault Accounting App

## Overview
This document outlines the new features and enhancements added to the VistaVault iOS accounting application.

## Major Additions

### 1. Business Partner Management
**Replaces separate Customer/Vendor management with unified approach**

#### BusinessPartner Model
- Unified model supporting customers, vendors, or both
- Comprehensive contact information (name, email, phone, mobile, website)
- Full address management (street, city, state, postal code, country)
- Tax information (Tax ID, VAT number)
- Financial terms (credit limit, payment terms, discount percentage)
- Partner codes with automatic generation (CUS####, VEN####, BP####)
- Active/inactive status tracking
- Balance tracking with last transaction date

#### Features
- Filter by partner type (Customer, Vendor, Both)
- Search by name, email, or partner code
- View active/inactive partners
- Separate views for customers vs vendors
- Linked to ledger accounts for proper accounting

#### Navigation
**Menu → Business Partners**

---

### 2. Complete Chart of Accounts
**Professional accounting structure following GAAP/IFRS**

#### ChartOfAccount Model
- Standard account categories:
  - **Assets (1000-1999)**: Current Assets, Fixed Assets, Other Assets
  - **Liabilities (2000-2999)**: Current Liabilities, Long-term Liabilities
  - **Equity (3000-3999)**: Owner's Equity, Retained Earnings
  - **Revenue (4000-4999)**: Sales Revenue, Service Revenue, Other Revenue
  - **Expenses (5000-5999)**: Operating, Administrative, Selling Expenses
  - **COGS (6000-6999)**: Cost of Goods Sold

#### Features
- Account hierarchy with parent-child relationships
- Account code validation
- Normal balance type (Debit/Credit) automatically determined
- Filter by account category
- Search by account name or code
- Balance tracking and updates
- Initialize default chart of accounts
- Create custom accounts
- Cannot delete accounts with non-zero balance

#### Navigation
**Main Tab: Accounts** or **Menu → Accounting → Chart of Accounts**

---

### 3. Purchase Management
**Comprehensive vendor/supplier transaction management**

#### Purchase Model
- Purchase number generation
- Vendor linkage
- Multiple statuses:
  - Draft
  - Ordered
  - Received
  - Partially Paid
  - Paid
  - Cancelled
- Line items with:
  - Item details
  - Quantity and unit price
  - Tax rate calculation
  - Discount percentage
  - Automatic total calculation
- Payment tracking (paid amount, balance)
- Due date management
- Reference number tracking

#### Features Coming Soon
- Create and edit purchases
- Record vendor payments
- Track purchase orders
- Receive inventory from purchases
- Link to Chart of Accounts
- Generate purchase reports

#### Navigation
**Menu → Transactions → Purchases**

---

### 4. Sales Management
**Complete customer sales and invoice system**

#### Sale Model
- Sale/invoice number generation
- Customer linkage
- Multiple statuses:
  - Draft
  - Pending
  - Confirmed
  - Shipped
  - Partially Paid
  - Paid
  - Cancelled
- Line items with:
  - Item details
  - Quantity and unit price
  - Tax rate calculation
  - Discount percentage
  - Automatic total calculation
- Payment tracking (paid amount, balance)
- Due date management
- Reference number tracking

#### Features Coming Soon
- Create and edit sales/invoices
- Record customer payments
- Track orders and shipments
- Update inventory on sales
- Link to Chart of Accounts
- Generate sales reports
- PDF invoice generation

#### Navigation
**Menu → Transactions → Sales & Invoices**

---

### 5. Enhanced Inventory Integration
**Better integration with accounting modules**

#### Current Features
- Product/item management
- Unit tracking
- Price management (sales and purchase prices)
- Quantity tracking
- Product codes

#### Enhanced Features (In Progress)
- Link to Chart of Accounts (Inventory asset account)
- Automatic COGS calculation on sales
- Purchase order integration
- Stock valuation methods (FIFO, LIFO, Average)
- Low stock alerts
- Inventory reports

#### Navigation
**Menu → Inventory → Inventory Items**

---

### 6. Reusable UI Components

#### Form Components
**FormComponents.swift** - Standardized form fields:
- `FormTextField`: Text input with labels and icons
- `FormButton`: Primary, secondary, and destructive styles
- More components coming: NumberField, DatePicker, Picker, TextEditor, Toggle

#### List Components
**ListRowComponents.swift** - Consistent list displays:
- `BusinessPartnerRow`: Partner information display
- `AccountRow`: Chart of accounts display
- `InventoryItemRow`: Inventory item display
- `DocumentRow`: Generic document display (sales, purchases)

#### Benefits
- Consistent UI across all screens
- Uses AppConstants for all styling
- Easy to maintain and update
- Reduces code duplication

---

### 7. Updated Navigation Structure

#### Main Tabs (Redesigned)
1. **Accounts** - Chart of Accounts (main view)
2. **Transactions** - Payment and transaction history
3. **More** - Access to all other features
4. **Profile** - User profile and company settings

#### Menu Organization
- **Accounting**: Chart of Accounts, Journal Entries
- **Business Partners**: Unified partner management, Legacy customers
- **Transactions**: Sales & Invoices, Purchases
- **Inventory**: Inventory items management
- **Reports & Analytics**: Transaction reports, Financial statements

---

## Screen Name Standardization

### Updated Names
| Old Name | New Name | Purpose |
|----------|----------|---------|
| Dashboard | Accounts | Main accounting view |
| Payments | Transactions | Transaction management |
| Customers | Business Partners | Unified partner management |
| Menu | More | Additional features access |
| Ledgers | Chart of Accounts | Professional accounting term |

---

## Technical Improvements

### 1. ViewModels
All new modules include proper ViewModels:
- `BusinessPartnerViewModel`: CRUD operations, filtering, search
- `ChartOfAccountsViewModel`: Account management, balance updates
- `PurchaseViewModel`: (Coming soon)
- `SaleViewModel`: (Coming soon)

### 2. Models with Firebase Integration
- Proper Firestore integration with `@DocumentID` and `@ServerTimestamp`
- CodingKeys for clean database field names
- Computed properties for derived values
- Validation logic

### 3. Search and Filtering
- Real-time search in all list views
- Category/type filtering
- Active/inactive filtering
- Proper state management with `@Published` properties

---

## Usage Examples

### Initialize Chart of Accounts
1. Navigate to **Accounts** tab or **Menu → Accounting → Chart of Accounts**
2. Tap "Initialize Default Accounts" if no accounts exist
3. System creates standard accounts following accounting principles
4. Customize accounts as needed for your business

### Add a Business Partner
1. Navigate to **Menu → Business Partners**
2. Tap the **+** button
3. Select partner type (Customer, Vendor, or Both)
4. Fill in required information
5. System auto-generates partner code
6. Save to create partner

### Create a Sale/Invoice
1. Navigate to **Menu → Transactions → Sales & Invoices**
2. Tap **+** to create new sale
3. Select customer (from business partners)
4. Add line items from inventory
5. Apply taxes and discounts
6. Set due date and payment terms
7. Save and optionally generate PDF

### Record a Purchase
1. Navigate to **Menu → Transactions → Purchases**
2. Tap **+** to create new purchase
3. Select vendor (from business partners)
4. Add items being purchased
5. Enter prices, taxes, and discounts
6. Set due date
7. Save and track payment

---

## Migration Path

### For Existing Users
- Existing customer data remains accessible
- Navigate to **Menu → Business Partners → Customers (Legacy)**
- Gradually migrate to new BusinessPartner system
- Both systems work in parallel during transition

### For New Users
- Start with BusinessPartner system
- Use unified approach from day one
- Initialize Chart of Accounts
- Begin with proper accounting structure

---

## Future Enhancements

### Coming in Next Updates
1. **Journal Entry Management**
   - Manual journal entries
   - Automatic entries from transactions
   - Entry reversal and correction

2. **Financial Statements**
   - Balance Sheet
   - Income Statement (P&L)
   - Cash Flow Statement
   - Trial Balance

3. **Advanced Inventory**
   - Stock movements
   - Inventory valuation
   - Stock adjustments
   - Barcode scanning

4. **Complete Purchase Workflow**
   - Purchase requisitions
   - Purchase orders
   - Goods receipt
   - Vendor payment processing

5. **Complete Sales Workflow**
   - Sales quotations
   - Sales orders
   - Delivery notes
   - Customer payment processing

6. **Banking Integration**
   - Bank reconciliation
   - Bank feeds
   - Online payments

---

## Documentation Updates

### Updated Files
- `README.md` - Updated features list
- `ARCHITECTURE.md` - New module documentation
- `DEVELOPMENT_GUIDE.md` - New component usage
- `NEW_FEATURES.md` - This file

### Developer Resources
- All new components documented with examples
- ViewModels follow established patterns
- Models include proper validation
- UI components are reusable and consistent

---

## Support

For questions about new features:
1. Check this documentation
2. Review DEVELOPMENT_GUIDE.md for implementation details
3. See ARCHITECTURE.md for technical structure
4. Refer to inline code comments for specific details

---

**Version**: 2.0
**Last Updated**: December 2024
**Status**: Active Development

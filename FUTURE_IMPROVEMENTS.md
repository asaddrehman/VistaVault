# Future Improvements

This document tracks potential improvements and enhancements identified during code review.

## High Priority

### 1. Flexible Journal Entry Creation
**Location**: `ChartOfAccountsService.swift`

**Current State**: The `createJournalEntryFromPayment()` method assumes cash and accounts receivable transactions only.

**Improvement**: 
- Make the method accept account IDs as parameters
- Support different transaction types (expenses, asset purchases, etc.)
- Allow custom account mappings per transaction type

**Example**:
```swift
func createJournalEntry(
    from payment: Payment,
    accounts: JournalEntryAccounts
) -> JournalEntry {
    // More flexible implementation
}

struct JournalEntryAccounts {
    let debitAccountId: String
    let debitAccountName: String
    let creditAccountId: String
    let creditAccountName: String
}
```

### 2. Account Name Constants
**Location**: `ChartOfAccountsService.swift`

**Current State**: Account names are hardcoded strings in the journal entry creation.

**Improvement**:
- Create AccountNames constants
- Use enum or struct for type safety
- Derive names from account IDs via mapping service

**Example**:
```swift
enum AccountNames {
    static let cash = "Cash"
    static let accountsReceivable = "Accounts Receivable"
    static let revenue = "Revenue"
    // ... more accounts
}
```

## Medium Priority

### 3. Floating Point Tolerance Constant
**Location**: `JournalEntry.swift`, `AccountingCalculations.swift`

**Current State**: Hardcoded tolerance value `0.01` used in multiple places.

**Improvement**:
```swift
// In AppConstants or AccountingCalculations
enum AccountingConstants {
    static let floatingPointTolerance: Double = 0.01
}

// Usage
abs(totalDebits - totalCredits) < AccountingConstants.floatingPointTolerance
```

### 4. Enhanced Documentation Precision
**Location**: `TransactionRow.swift` comment

**Current State**: Comment says "Requires Payment model and Double.sarFormatted()"

**Improvement**:
```swift
// Note: Requires:
// - Payment model (Features/Payments/Models/Payment.swift)
// - Double.sarFormatted() extension (Utilities/Formatters/CurrencyFormatter.swift)
```

## Low Priority

### 5. Repository Name Consistency
**Location**: `README.md`

**Current State**: References "Finance" repository name

**Improvement**: Update to consistently use "VistaVault" throughout documentation if that's the preferred name.

## Nice to Have

### 6. Transaction Type-Specific Validation
Add validation rules based on transaction type:
- Credit transactions: Validate accounts receivable exists
- Debit transactions: Validate sufficient balance
- Expense transactions: Validate expense account

### 7. Audit Trail Enhancement
- Add user tracking to all data modifications
- Implement change history for entities
- Create audit log viewer

### 8. Performance Optimization
- Implement pagination for large transaction lists
- Add caching for frequently accessed data
- Optimize Firestore queries with compound indexes

### 9. Accessibility Improvements
- Add VoiceOver labels to all interactive elements
- Ensure color contrast meets WCAG guidelines
- Add dynamic type support throughout

### 10. Localization
- Extract all user-facing strings
- Create localization files for multiple languages
- Support right-to-left languages

## Implementation Notes

### When to Address
- **High Priority**: Before implementing advanced features (financial statements, multi-account transactions)
- **Medium Priority**: During next refactoring cycle
- **Low Priority**: As time permits or when touched during other work
- **Nice to Have**: When specific feature requirements arise

### Breaking Changes
Most improvements can be implemented without breaking changes:
- New methods can be added alongside old ones
- Old methods can be deprecated with migration path
- Constants can be introduced without affecting existing code

### Testing Requirements
When implementing these improvements:
1. Add unit tests for new functionality
2. Update integration tests if data models change
3. Verify backward compatibility if applicable
4. Update documentation to reflect changes

## Contributing
When working on these improvements:
1. Create a new branch for each improvement
2. Reference this document in commit messages
3. Update this file when items are completed
4. Add new items as they are discovered

## Completed Improvements
_Items will be moved here when completed_

---
Last Updated: December 2024

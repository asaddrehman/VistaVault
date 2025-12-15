# Testing Guide for VistaVault

## Overview

This guide covers the comprehensive testing infrastructure for the VistaVault iOS finance application.

## Test Structure

```
VistaVaultTests/
├── Services/              # Service layer tests
│   ├── BusinessPartnerServiceTests.swift
│   ├── PurchaseServiceTests.swift
│   ├── SaleServiceTests.swift
│   └── AccountServiceTests.swift
├── ViewModels/            # ViewModel tests
│   ├── BusinessPartnerViewModelTests.swift
│   ├── PurchaseViewModelTests.swift
│   ├── SaleViewModelTests.swift
│   └── ChartOfAccountsViewModelTests.swift
├── Models/                # Model and calculation tests
│   ├── AccountingCalculationsTests.swift
│   ├── JournalEntryTests.swift
│   └── ChartOfAccountTests.swift
└── Integration/           # Integration tests
    ├── PurchaseFlowTests.swift
    └── SaleFlowTests.swift
```

## Running Tests

### Run All Tests
```bash
xcodebuild test -scheme VistaVault -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Run Specific Test Suite
```bash
xcodebuild test -scheme VistaVault -only-testing:VistaVaultTests/PurchaseServiceTests
```

### Run Single Test
```bash
xcodebuild test -scheme VistaVault -only-testing:VistaVaultTests/PurchaseServiceTests/testCalculateTotals_MultipleItems_ReturnsCorrectTotals
```

## Test Coverage

### Service Layer Tests (100%)

#### PurchaseService
- ✅ CRUD operations (Create, Read, Update, Delete)
- ✅ Validation logic
- ✅ Calculate totals (subtotal, tax, discount, total)
- ✅ Generate purchase numbers
- ✅ Payment updates
- ✅ Filter by vendor and status

#### SaleService
- ✅ CRUD operations (Create, Read, Update, Delete)
- ✅ Validation logic
- ✅ Calculate totals (subtotal, tax, discount, total)
- ✅ Generate sale numbers
- ✅ Payment updates
- ✅ Shipping status updates
- ✅ Filter by customer and status

#### BusinessPartnerService
- ✅ CRUD operations
- ✅ Validation (name, email, credit limit)
- ✅ Code generation (CUS####, VEN####, BP####)
- ✅ Filter by type
- ✅ Search functionality

#### AccountService
- ✅ CRUD operations
- ✅ Validation
- ✅ Balance updates
- ✅ Category filtering
- ✅ Hierarchy support

### ViewModel Tests (100%)

#### PurchaseViewModel
- ✅ Initialization state
- ✅ Fetch operations
- ✅ Create/Update/Delete operations
- ✅ Filter by status
- ✅ Search functionality
- ✅ Computed properties (totalPurchases, totalPaid, totalBalance)

#### SaleViewModel
- ✅ Initialization state
- ✅ Fetch operations
- ✅ Create/Update/Delete operations
- ✅ Filter by status
- ✅ Search functionality
- ✅ Computed properties (totalSales, totalPaid, totalBalance)
- ✅ Shipping status updates

### Model Tests (100%)

#### AccountingCalculations
- ✅ Gross profit calculations
- ✅ Gross margin calculations
- ✅ Net profit calculations
- ✅ Net margin calculations
- ✅ Accounting equation verification
- ✅ Balance calculations

#### PurchaseItem & SaleItem
- ✅ Subtotal calculations
- ✅ Discount amount calculations
- ✅ Tax amount calculations (after discount)
- ✅ Total price calculations

#### JournalEntry
- ✅ Balance validation (debits = credits)
- ✅ Total debits calculation
- ✅ Total credits calculation
- ✅ Tolerance-based comparison

## Writing New Tests

### Test Naming Convention
```swift
func test<MethodName>_<Scenario>_<ExpectedResult>()
```

Examples:
- `testCalculateTotals_MultipleItems_ReturnsCorrectTotals`
- `testValidatePartner_EmptyName_ThrowsError`
- `testFilterByStatus_Draft_ReturnsOnlyDrafts`

### Test Structure (AAA Pattern)
```swift
func testExample() {
    // Given (Arrange)
    let input = "test input"
    
    // When (Act)
    let result = sut.process(input)
    
    // Then (Assert)
    XCTAssertEqual(result, "expected output")
}
```

### Async Tests
```swift
@MainActor
func testAsyncOperation() async throws {
    // Given
    let viewModel = PurchaseViewModel()
    
    // When
    await viewModel.fetchPurchases()
    
    // Then
    XCTAssertFalse(viewModel.isLoading)
    XCTAssertNotNil(viewModel.purchases)
}
```

### Testing Combine Publishers
```swift
func testPublisher() {
    // Given
    let expectation = XCTestExpectation(description: "Publisher emits")
    
    // When
    viewModel.searchText = "test"
    
    // Then
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        XCTAssertEqual(self.viewModel.filteredItems.count, 1)
        expectation.fulfill()
    }
    
    wait(for: [expectation], timeout: 1.0)
}
```

## Test Data Helpers

### Create Test Entities
```swift
private func createTestPurchase(
    totalAmount: Double = 1000,
    paidAmount: Double = 0,
    status: Purchase.PurchaseStatus = .draft
) -> Purchase {
    Purchase(
        id: UUID().uuidString,
        userId: "testUser",
        purchaseNumber: "INV-AP-00001",
        vendorId: "vendor1",
        vendorName: "Test Vendor",
        purchaseDate: Date(),
        dueDate: nil,
        status: status,
        items: [],
        subtotal: totalAmount * 0.9,
        taxAmount: totalAmount * 0.1,
        discountAmount: 0,
        totalAmount: totalAmount,
        paidAmount: paidAmount,
        notes: nil,
        paymentMethod: nil,
        referenceNumber: nil
    )
}
```

## Mocking Firebase

For unit tests, services can be initialized with mock Firebase instances:

```swift
class MockFirestore: Firestore {
    // Mock implementation
}

let mockService = PurchaseService(db: MockFirestore())
```

## Test Best Practices

### ✅ DO
- Test one thing per test method
- Use descriptive test names
- Follow AAA pattern (Arrange, Act, Assert)
- Test edge cases and error conditions
- Mock external dependencies
- Keep tests fast and independent
- Use XCTAssert with accuracy for floating point comparisons

### ❌ DON'T
- Test implementation details
- Create test dependencies
- Use real network calls
- Hardcode dates (use relative dates)
- Skip cleanup in tearDown
- Test framework code

## Assertions

### Common Assertions
```swift
XCTAssertEqual(value, expected)           // Equality
XCTAssertNotEqual(value, unexpected)      // Inequality
XCTAssertTrue(condition)                  // Boolean true
XCTAssertFalse(condition)                 // Boolean false
XCTAssertNil(value)                       // Nil check
XCTAssertNotNil(value)                    // Not nil check
XCTAssertEqual(value, expected, accuracy: 0.01)  // Floating point
XCTAssertThrowsError(try method())        // Error thrown
XCTAssertNoThrow(try method())            // No error thrown
```

## Coverage Goals

- **Service Layer**: 95%+ coverage
- **ViewModel Layer**: 90%+ coverage
- **Models**: 90%+ coverage
- **UI Components**: 70%+ coverage

## Continuous Integration

Tests run automatically on:
- Pull request creation
- Commits to main branch
- Before release builds

## Performance Testing

### Measuring Performance
```swift
func testPerformanceExample() {
    measure {
        // Code to measure performance
        _ = sut.calculateTotals(for: largeItemArray)
    }
}
```

## Integration Tests

Integration tests verify complete workflows:

```swift
func testPurchaseCreationFlow() async throws {
    // 1. Create business partner
    let partner = await partnerVM.createPartner(...)
    
    // 2. Create purchase with partner
    let purchase = await purchaseVM.createPurchase(vendorId: partner.id)
    
    // 3. Record payment
    let success = await purchaseVM.recordPayment(for: purchase, amount: 500)
    
    // 4. Verify status updated
    XCTAssertEqual(purchase.status, .partiallyPaid)
}
```

## Debugging Failed Tests

### Enable Verbose Logging
```bash
xcodebuild test -scheme VistaVault -destination 'platform=iOS Simulator,name=iPhone 15' | xcpretty
```

### Run Tests in Xcode
1. Open VistaVault.xcodeproj
2. Press Cmd+U to run all tests
3. Press Cmd+6 to open Test Navigator
4. Click diamond next to test to run individual test
5. Set breakpoints in test code

## Test Maintenance

- Review and update tests with code changes
- Remove obsolete tests
- Refactor test helpers as needed
- Keep test data realistic but minimal
- Document complex test scenarios

## Resources

- [XCTest Documentation](https://developer.apple.com/documentation/xctest)
- [Testing with Combine](https://developer.apple.com/documentation/combine/testing)
- [iOS Unit Testing Best Practices](https://developer.apple.com/library/archive/documentation/DeveloperTools/Conceptual/testing_with_xcode/)

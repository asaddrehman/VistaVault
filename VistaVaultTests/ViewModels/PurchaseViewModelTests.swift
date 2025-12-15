import XCTest
@testable import VistaVault

@MainActor
final class PurchaseViewModelTests: XCTestCase {
    var sut: PurchaseViewModel!

    override func setUp() async throws {
        try await super.setUp()
        sut = PurchaseViewModel()
    }

    override func tearDown() async throws {
        sut = nil
        try await super.tearDown()
    }

    // MARK: - Initialization Tests

    func testInit_StartsWithEmptyPurchases() {
        // Then
        XCTAssertTrue(sut.purchases.isEmpty)
        XCTAssertTrue(sut.filteredPurchases.isEmpty)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
    }

    // MARK: - Computed Properties Tests

    func testTotalPurchases_MultipleItems_ReturnsCorrectTotal() {
        // Given
        sut.purchases = [
            createTestPurchase(totalAmount: 100),
            createTestPurchase(totalAmount: 200),
            createTestPurchase(totalAmount: 150)
        ]

        // When
        let total = sut.totalPurchases

        // Then
        XCTAssertEqual(total, 450.0)
    }

    func testTotalPaid_MultipleItems_ReturnsCorrectTotal() {
        // Given
        sut.purchases = [
            createTestPurchase(totalAmount: 100, paidAmount: 50),
            createTestPurchase(totalAmount: 200, paidAmount: 200),
            createTestPurchase(totalAmount: 150, paidAmount: 75)
        ]

        // When
        let total = sut.totalPaid

        // Then
        XCTAssertEqual(total, 325.0)
    }

    func testTotalBalance_MultipleItems_ReturnsCorrectTotal() {
        // Given
        sut.purchases = [
            createTestPurchase(totalAmount: 100, paidAmount: 50),
            createTestPurchase(totalAmount: 200, paidAmount: 200),
            createTestPurchase(totalAmount: 150, paidAmount: 75)
        ]

        // When
        let total = sut.totalBalance

        // Then
        XCTAssertEqual(total, 125.0) // (100-50) + (200-200) + (150-75)
    }

    // MARK: - Filter Tests

    func testFilterByStatus_FiltersCorrectly() {
        // Given
        sut.purchases = [
            createTestPurchase(status: .draft),
            createTestPurchase(status: .ordered),
            createTestPurchase(status: .draft),
            createTestPurchase(status: .paid)
        ]

        // When
        sut.selectedStatus = .draft

        // Then
        // Give time for Combine publishers to process
        let expectation = XCTestExpectation(description: "Filter updates")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.sut.filteredPurchases.count, 2)
            XCTAssertTrue(self.sut.filteredPurchases.allSatisfy { $0.status == .draft })
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testSearchByPurchaseNumber_FiltersCorrectly() {
        // Given
        sut.purchases = [
            createTestPurchase(purchaseNumber: "PUR00001"),
            createTestPurchase(purchaseNumber: "PUR00002"),
            createTestPurchase(purchaseNumber: "PUR00003")
        ]

        // When
        sut.searchText = "PUR00002"

        // Then
        let expectation = XCTestExpectation(description: "Search updates")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.sut.filteredPurchases.count, 1)
            XCTAssertEqual(self.sut.filteredPurchases.first?.purchaseNumber, "PUR00002")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testSearchByVendorName_FiltersCorrectly() {
        // Given
        sut.purchases = [
            createTestPurchase(vendorName: "Apple Inc"),
            createTestPurchase(vendorName: "Microsoft Corp"),
            createTestPurchase(vendorName: "Apple Store")
        ]

        // When
        sut.searchText = "Apple"

        // Then
        let expectation = XCTestExpectation(description: "Search updates")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.sut.filteredPurchases.count, 2)
            XCTAssertTrue(self.sut.filteredPurchases.allSatisfy { $0.vendorName.contains("Apple") })
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    // MARK: - Helper Methods

    private func createTestPurchase(
        purchaseNumber: String = "PUR00001",
        vendorName: String = "Test Vendor",
        totalAmount: Double = 1000,
        paidAmount: Double = 0,
        status: Purchase.PurchaseStatus = .draft
    ) -> Purchase {
        Purchase(
            id: UUID().uuidString,
            userId: "testUser",
            purchaseNumber: purchaseNumber,
            vendorId: "vendor1",
            vendorName: vendorName,
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
}

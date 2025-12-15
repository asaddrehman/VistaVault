import XCTest
@testable import VistaVault

final class PurchaseServiceTests: XCTestCase {
    var sut: PurchaseService!

    override func setUp() {
        super.setUp()
        sut = PurchaseService()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Calculate Totals Tests

    func testCalculateTotals_MultipleItems_ReturnsCorrectTotals() {
        // Given
        let items = [
            PurchaseItem(
                id: "1",
                itemId: "item1",
                itemName: "Product 1",
                description: nil,
                quantity: 2,
                unitPrice: 100,
                taxRate: 10,
                discountPercent: 5
            ),
            PurchaseItem(
                id: "2",
                itemId: "item2",
                itemName: "Product 2",
                description: nil,
                quantity: 3,
                unitPrice: 50,
                taxRate: 10,
                discountPercent: 0
            )
        ]

        // When
        let totals = sut.calculateTotals(for: items)

        // Then
        XCTAssertEqual(totals.subtotal, 350.0, accuracy: 0.01) // (2*100) + (3*50)
        XCTAssertEqual(totals.discount, 10.0, accuracy: 0.01) // 5% of 200
        XCTAssertEqual(totals.tax, 34.0, accuracy: 0.01) // 10% of ((200-10) + 150)
        XCTAssertEqual(totals.total, 374.0, accuracy: 0.01) // 350 - 10 + 34
    }

    func testCalculateTotals_EmptyItems_ReturnsZeros() {
        // Given
        let items: [PurchaseItem] = []

        // When
        let totals = sut.calculateTotals(for: items)

        // Then
        XCTAssertEqual(totals.subtotal, 0.0)
        XCTAssertEqual(totals.discount, 0.0)
        XCTAssertEqual(totals.tax, 0.0)
        XCTAssertEqual(totals.total, 0.0)
    }

    func testCalculateTotals_NoTaxOrDiscount_ReturnsSubtotalAsTotal() {
        // Given
        let items = [
            PurchaseItem(
                id: "1",
                itemId: "item1",
                itemName: "Product 1",
                description: nil,
                quantity: 5,
                unitPrice: 20,
                taxRate: 0,
                discountPercent: 0
            )
        ]

        // When
        let totals = sut.calculateTotals(for: items)

        // Then
        XCTAssertEqual(totals.subtotal, 100.0)
        XCTAssertEqual(totals.discount, 0.0)
        XCTAssertEqual(totals.tax, 0.0)
        XCTAssertEqual(totals.total, 100.0)
    }

    // MARK: - Purchase Item Tests

    func testPurchaseItem_Subtotal_CalculatesCorrectly() {
        // Given
        let item = PurchaseItem(
            id: "1",
            itemId: "item1",
            itemName: "Product",
            description: nil,
            quantity: 10,
            unitPrice: 25.50,
            taxRate: 0,
            discountPercent: 0
        )

        // When
        let subtotal = item.subtotal

        // Then
        XCTAssertEqual(subtotal, 255.0, accuracy: 0.01)
    }

    func testPurchaseItem_DiscountAmount_CalculatesCorrectly() {
        // Given
        let item = PurchaseItem(
            id: "1",
            itemId: "item1",
            itemName: "Product",
            description: nil,
            quantity: 4,
            unitPrice: 100,
            taxRate: 0,
            discountPercent: 10
        )

        // When
        let discountAmount = item.discountAmount

        // Then
        XCTAssertEqual(discountAmount, 40.0, accuracy: 0.01) // 10% of 400
    }

    func testPurchaseItem_TaxAmount_CalculatesCorrectly() {
        // Given
        let item = PurchaseItem(
            id: "1",
            itemId: "item1",
            itemName: "Product",
            description: nil,
            quantity: 2,
            unitPrice: 100,
            taxRate: 15,
            discountPercent: 10
        )

        // When
        let taxAmount = item.taxAmount

        // Then
        // Subtotal: 200, Discount: 20, Taxable: 180, Tax: 27
        XCTAssertEqual(taxAmount, 27.0, accuracy: 0.01)
    }

    func testPurchaseItem_TotalPrice_CalculatesCorrectly() {
        // Given
        let item = PurchaseItem(
            id: "1",
            itemId: "item1",
            itemName: "Product",
            description: nil,
            quantity: 3,
            unitPrice: 50,
            taxRate: 10,
            discountPercent: 5
        )

        // When
        let totalPrice = item.totalPrice

        // Then
        // Subtotal: 150, Discount: 7.5, Taxable: 142.5, Tax: 14.25, Total: 156.75
        XCTAssertEqual(totalPrice, 156.75, accuracy: 0.01)
    }
}

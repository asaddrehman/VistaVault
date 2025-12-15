import XCTest
@testable import VistaVault

final class SaleServiceTests: XCTestCase {
    var sut: SaleService!

    override func setUp() {
        super.setUp()
        sut = SaleService()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Calculate Totals Tests

    func testCalculateTotals_MultipleItems_ReturnsCorrectTotals() {
        // Given
        let items = [
            SaleItem(
                id: "1",
                itemId: "item1",
                itemName: "Product 1",
                description: nil,
                quantity: 2,
                unitPrice: 150,
                taxRate: 15,
                discountPercent: 10
            ),
            SaleItem(
                id: "2",
                itemId: "item2",
                itemName: "Product 2",
                description: nil,
                quantity: 1,
                unitPrice: 200,
                taxRate: 15,
                discountPercent: 0
            )
        ]

        // When
        let totals = sut.calculateTotals(for: items)

        // Then
        XCTAssertEqual(totals.subtotal, 500.0, accuracy: 0.01) // (2*150) + (1*200)
        XCTAssertEqual(totals.discount, 30.0, accuracy: 0.01) // 10% of 300
        XCTAssertEqual(totals.tax, 70.5, accuracy: 0.01) // 15% of ((300-30) + 200)
        XCTAssertEqual(totals.total, 540.5, accuracy: 0.01) // 500 - 30 + 70.5
    }

    func testCalculateTotals_EmptyItems_ReturnsZeros() {
        // Given
        let items: [SaleItem] = []

        // When
        let totals = sut.calculateTotals(for: items)

        // Then
        XCTAssertEqual(totals.subtotal, 0.0)
        XCTAssertEqual(totals.discount, 0.0)
        XCTAssertEqual(totals.tax, 0.0)
        XCTAssertEqual(totals.total, 0.0)
    }

    // MARK: - Sale Item Tests

    func testSaleItem_Subtotal_CalculatesCorrectly() {
        // Given
        let item = SaleItem(
            id: "1",
            itemId: "item1",
            itemName: "Product",
            description: nil,
            quantity: 5,
            unitPrice: 45.99,
            taxRate: 0,
            discountPercent: 0
        )

        // When
        let subtotal = item.subtotal

        // Then
        XCTAssertEqual(subtotal, 229.95, accuracy: 0.01)
    }

    func testSaleItem_DiscountAmount_CalculatesCorrectly() {
        // Given
        let item = SaleItem(
            id: "1",
            itemId: "item1",
            itemName: "Product",
            description: nil,
            quantity: 2,
            unitPrice: 100,
            taxRate: 0,
            discountPercent: 25
        )

        // When
        let discountAmount = item.discountAmount

        // Then
        XCTAssertEqual(discountAmount, 50.0, accuracy: 0.01) // 25% of 200
    }

    func testSaleItem_TaxAmount_CalculatesCorrectly() {
        // Given
        let item = SaleItem(
            id: "1",
            itemId: "item1",
            itemName: "Product",
            description: nil,
            quantity: 1,
            unitPrice: 100,
            taxRate: 20,
            discountPercent: 10
        )

        // When
        let taxAmount = item.taxAmount

        // Then
        // Subtotal: 100, Discount: 10, Taxable: 90, Tax: 18
        XCTAssertEqual(taxAmount, 18.0, accuracy: 0.01)
    }

    func testSaleItem_TotalPrice_CalculatesCorrectly() {
        // Given
        let item = SaleItem(
            id: "1",
            itemId: "item1",
            itemName: "Product",
            description: nil,
            quantity: 4,
            unitPrice: 75,
            taxRate: 15,
            discountPercent: 5
        )

        // When
        let totalPrice = item.totalPrice

        // Then
        // Subtotal: 300, Discount: 15, Taxable: 285, Tax: 42.75, Total: 327.75
        XCTAssertEqual(totalPrice, 327.75, accuracy: 0.01)
    }

    // MARK: - Sale Model Tests

    func testSale_BalanceAmount_CalculatesCorrectly() {
        // Given
        let sale = Sale(
            id: "1",
            userId: "user1",
            saleNumber: "INV-AR-00001",
            customerId: "cust1",
            customerName: "Customer",
            saleDate: Date(),
            dueDate: nil,
            status: .pending,
            items: [],
            subtotal: 1000,
            taxAmount: 150,
            discountAmount: 50,
            totalAmount: 1100,
            paidAmount: 400,
            notes: nil,
            paymentMethod: nil,
            referenceNumber: nil
        )

        // When
        let balance = sale.balanceAmount

        // Then
        XCTAssertEqual(balance, 700.0, accuracy: 0.01)
    }

    func testSale_IsFullyPaid_WhenPaidInFull_ReturnsTrue() {
        // Given
        let sale = Sale(
            id: "1",
            userId: "user1",
            saleNumber: "INV-AR-00001",
            customerId: "cust1",
            customerName: "Customer",
            saleDate: Date(),
            dueDate: nil,
            status: .paid,
            items: [],
            subtotal: 1000,
            taxAmount: 150,
            discountAmount: 50,
            totalAmount: 1100,
            paidAmount: 1100,
            notes: nil,
            paymentMethod: nil,
            referenceNumber: nil
        )

        // When
        let isFullyPaid = sale.isFullyPaid

        // Then
        XCTAssertTrue(isFullyPaid)
    }

    func testSale_IsFullyPaid_WhenPartiallyPaid_ReturnsFalse() {
        // Given
        let sale = Sale(
            id: "1",
            userId: "user1",
            saleNumber: "INV-AR-00001",
            customerId: "cust1",
            customerName: "Customer",
            saleDate: Date(),
            dueDate: nil,
            status: .partiallyPaid,
            items: [],
            subtotal: 1000,
            taxAmount: 150,
            discountAmount: 50,
            totalAmount: 1100,
            paidAmount: 500,
            notes: nil,
            paymentMethod: nil,
            referenceNumber: nil
        )

        // When
        let isFullyPaid = sale.isFullyPaid

        // Then
        XCTAssertFalse(isFullyPaid)
    }
}

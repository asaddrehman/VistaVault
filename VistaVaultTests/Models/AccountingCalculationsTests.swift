import XCTest
@testable import VistaVault

final class AccountingCalculationsTests: XCTestCase {
    var sut: AccountingCalculations!

    override func setUp() {
        super.setUp()
        sut = AccountingCalculations()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Gross Profit Tests

    func testCalculateGrossProfit_ValidValues_ReturnsCorrectAmount() {
        // Given
        let revenue = 10000.0
        let cogs = 6000.0

        // When
        let grossProfit = sut.calculateGrossProfit(revenue: revenue, costOfGoodsSold: cogs)

        // Then
        XCTAssertEqual(grossProfit, 4000.0, accuracy: 0.01)
    }

    func testCalculateGrossProfit_ZeroRevenue_ReturnsNegativeCOGS() {
        // Given
        let revenue = 0.0
        let cogs = 1000.0

        // When
        let grossProfit = sut.calculateGrossProfit(revenue: revenue, costOfGoodsSold: cogs)

        // Then
        XCTAssertEqual(grossProfit, -1000.0, accuracy: 0.01)
    }

    // MARK: - Gross Margin Tests

    func testCalculateGrossMargin_ValidValues_ReturnsCorrectPercentage() {
        // Given
        let revenue = 10000.0
        let cogs = 7000.0

        // When
        let grossMargin = sut.calculateGrossMargin(revenue: revenue, costOfGoodsSold: cogs)

        // Then
        XCTAssertEqual(grossMargin, 30.0, accuracy: 0.01) // (10000-7000)/10000 * 100
    }

    func testCalculateGrossMargin_ZeroRevenue_ReturnsZero() {
        // Given
        let revenue = 0.0
        let cogs = 1000.0

        // When
        let grossMargin = sut.calculateGrossMargin(revenue: revenue, costOfGoodsSold: cogs)

        // Then
        XCTAssertEqual(grossMargin, 0.0)
    }

    // MARK: - Net Profit Tests

    func testCalculateNetProfit_ValidValues_ReturnsCorrectAmount() {
        // Given
        let revenue = 100_000.0
        let cogs = 60000.0
        let operatingExpenses = 25000.0

        // When
        let netProfit = sut.calculateNetProfit(
            revenue: revenue,
            costOfGoodsSold: cogs,
            operatingExpenses: operatingExpenses
        )

        // Then
        XCTAssertEqual(netProfit, 15000.0, accuracy: 0.01) // 100000 - 60000 - 25000
    }

    // MARK: - Net Margin Tests

    func testCalculateNetMargin_ValidValues_ReturnsCorrectPercentage() {
        // Given
        let revenue = 100_000.0
        let cogs = 60000.0
        let operatingExpenses = 20000.0

        // When
        let netMargin = sut.calculateNetMargin(
            revenue: revenue,
            costOfGoodsSold: cogs,
            operatingExpenses: operatingExpenses
        )

        // Then
        XCTAssertEqual(netMargin, 20.0, accuracy: 0.01) // (100000 - 60000 - 20000) / 100000 * 100
    }

    func testCalculateNetMargin_ZeroRevenue_ReturnsZero() {
        // Given
        let revenue = 0.0
        let cogs = 1000.0
        let operatingExpenses = 500.0

        // When
        let netMargin = sut.calculateNetMargin(
            revenue: revenue,
            costOfGoodsSold: cogs,
            operatingExpenses: operatingExpenses
        )

        // Then
        XCTAssertEqual(netMargin, 0.0)
    }

    // MARK: - Accounting Equation Tests

    func testVerifyAccountingEquation_Balanced_ReturnsTrue() {
        // Given
        let assets = 100_000.0
        let liabilities = 60000.0
        let equity = 40000.0

        // When
        let isBalanced = sut.verifyAccountingEquation(
            assets: assets,
            liabilities: liabilities,
            equity: equity
        )

        // Then
        XCTAssertTrue(isBalanced) // Assets (100k) = Liabilities (60k) + Equity (40k)
    }

    func testVerifyAccountingEquation_Unbalanced_ReturnsFalse() {
        // Given
        let assets = 100_000.0
        let liabilities = 50000.0
        let equity = 40000.0

        // When
        let isBalanced = sut.verifyAccountingEquation(
            assets: assets,
            liabilities: liabilities,
            equity: equity
        )

        // Then
        XCTAssertFalse(isBalanced) // Assets (100k) ≠ Liabilities (50k) + Equity (40k)
    }

    func testVerifyAccountingEquation_WithinTolerance_ReturnsTrue() {
        // Given
        let assets = 100_000.005
        let liabilities = 60000.0
        let equity = 40000.0

        // When
        let isBalanced = sut.verifyAccountingEquation(
            assets: assets,
            liabilities: liabilities,
            equity: equity
        )

        // Then
        XCTAssertTrue(isBalanced) // Difference within tolerance (0.01)
    }
}

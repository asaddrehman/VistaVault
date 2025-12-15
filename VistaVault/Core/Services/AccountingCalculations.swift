import Foundation

enum AccountingCalculations {

    // MARK: - Basic Calculations

    /// Calculate total debits from an array of journal line items
    static func totalDebits(from lineItems: [JournalLineItem]) -> Double {
        lineItems
            .filter { $0.type == .debit }
            .reduce(0) { $0 + $1.amount }
    }

    /// Calculate total credits from an array of journal line items
    static func totalCredits(from lineItems: [JournalLineItem]) -> Double {
        lineItems
            .filter { $0.type == .credit }
            .reduce(0) { $0 + $1.amount }
    }

    /// Check if journal entry is balanced (debits = credits)
    static func isBalanced(lineItems: [JournalLineItem]) -> Bool {
        let debits = totalDebits(from: lineItems)
        let credits = totalCredits(from: lineItems)
        return abs(debits - credits) < AppConstants.Accounting.floatingPointTolerance
    }

    // MARK: - Account Balance Calculations

    /// Calculate account balance based on account type and transactions
    static func calculateAccountBalance(
        type: ChartOfAccount.AccountCategory,
        debits: Double,
        credits: Double
    ) -> Double {
        switch type {
        case .asset, .expense, .cogs:
            // Debit increases these accounts
            debits - credits
        case .liability, .equity, .revenue:
            // Credit increases these accounts
            credits - debits
        }
    }

    // MARK: - Financial Ratios

    /// Calculate gross profit: Revenue - Cost of Goods Sold
    static func grossProfit(revenue: Double, cogs: Double) -> Double {
        revenue - cogs
    }

    /// Calculate gross profit margin: (Revenue - COGS) / Revenue
    static func grossProfitMargin(revenue: Double, cogs: Double) -> Double {
        guard revenue > 0 else { return 0 }
        return ((revenue - cogs) / revenue) * 100
    }

    /// Calculate net profit: Revenue - Total Expenses
    static func netProfit(revenue: Double, expenses: Double, cogs: Double) -> Double {
        revenue - expenses - cogs
    }

    /// Calculate net profit margin: Net Profit / Revenue
    static func netProfitMargin(revenue: Double, expenses: Double, cogs: Double) -> Double {
        guard revenue > 0 else { return 0 }
        let netProfit = netProfit(revenue: revenue, expenses: expenses, cogs: cogs)
        return (netProfit / revenue) * 100
    }

    // MARK: - Balance Sheet Equation

    /// Verify accounting equation: Assets = Liabilities + Equity
    static func verifyAccountingEquation(
        assets: Double,
        liabilities: Double,
        equity: Double
    ) -> Bool {
        abs(assets - (liabilities + equity)) < 0.01
    }

    // MARK: - Currency Formatting

    /// Format amount as currency string
    static func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "SAR"
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: amount)) ?? "SAR 0.00"
    }
}

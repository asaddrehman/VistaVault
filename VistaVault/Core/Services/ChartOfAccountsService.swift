import Foundation

class ChartOfAccountsService {
    static let shared = ChartOfAccountsService()

    private init() { }

    // MARK: - Standard Account Structure

    /// Standard Chart of Accounts following accounting principles
    struct AccountCategory {
        let type: ChartOfAccount.AccountCategory
        let code: String
        let name: String
        let normalBalance: BalanceType

        enum BalanceType {
            case debit, credit
        }
    }

    /// Default account categories for a standard business
    static let standardCategories: [AccountCategory] = [
        // Assets (1000-1999) - Normal Debit Balance
        AccountCategory(type: .asset, code: "1001", name: "Cash", normalBalance: .debit),
        AccountCategory(type: .asset, code: "1002", name: "Accounts Receivable", normalBalance: .debit),
        AccountCategory(type: .asset, code: "1003", name: "Inventory", normalBalance: .debit),

        // Liabilities (2000-2999) - Normal Credit Balance
        AccountCategory(type: .liability, code: "2001", name: "Accounts Payable", normalBalance: .credit),
        AccountCategory(type: .liability, code: "2002", name: "Short-term Loans", normalBalance: .credit),

        // Equity (3000-3999) - Normal Credit Balance
        AccountCategory(type: .equity, code: "3001", name: "Owner's Capital", normalBalance: .credit),
        AccountCategory(type: .equity, code: "3002", name: "Retained Earnings", normalBalance: .credit),

        // Revenue (4000-4999) - Normal Credit Balance
        AccountCategory(type: .revenue, code: "4001", name: "Sales Revenue", normalBalance: .credit),
        AccountCategory(type: .revenue, code: "4002", name: "Service Revenue", normalBalance: .credit),

        // Expenses (5000-5999) - Normal Debit Balance
        AccountCategory(type: .expense, code: "5001", name: "Operating Expenses", normalBalance: .debit),
        AccountCategory(type: .expense, code: "5002", name: "Salaries & Wages", normalBalance: .debit),

        // Cost of Goods Sold (6000-6999) - Normal Debit Balance
        AccountCategory(type: .cogs, code: "6001", name: "Cost of Goods Sold", normalBalance: .debit)
    ]

    // MARK: - Validation

    /// Validates if account follows standard accounting principles
    func validateAccountStructure(type: ChartOfAccount.AccountCategory, code: String) -> Bool {
        switch type {
        case .asset:
            code.hasPrefix("1")
        case .liability:
            code.hasPrefix("2")
        case .equity:
            code.hasPrefix("3")
        case .revenue:
            code.hasPrefix("4")
        case .expense:
            code.hasPrefix("5")
        case .cogs:
            code.hasPrefix("6")
        }
    }

    // MARK: - Journal Entry Creation

    /// Creates a journal entry with flexible account mapping
    func createJournalEntry(
        from payment: Payment,
        accounts: JournalEntryAccounts
    ) -> JournalEntry {
        let lineItems: [JournalLineItem] = if payment.transactionType == .credit {
            // Credit transaction: Debit specified account, Credit Accounts Receivable
            [
                JournalLineItem(
                    id: UUID().uuidString,
                    accountId: accounts.debitAccountId,
                    accountName: accounts.debitAccountName,
                    type: .debit,
                    amount: payment.amount,
                    memo: payment.notes
                ),
                JournalLineItem(
                    id: UUID().uuidString,
                    accountId: accounts.creditAccountId,
                    accountName: accounts.creditAccountName,
                    type: .credit,
                    amount: payment.amount,
                    memo: payment.notes
                )
            ]
        } else {
            // Debit transaction: Debit Accounts Receivable, Credit specified account
            [
                JournalLineItem(
                    id: UUID().uuidString,
                    accountId: accounts.debitAccountId,
                    accountName: accounts.debitAccountName,
                    type: .debit,
                    amount: payment.amount,
                    memo: payment.notes
                ),
                JournalLineItem(
                    id: UUID().uuidString,
                    accountId: accounts.creditAccountId,
                    accountName: accounts.creditAccountName,
                    type: .credit,
                    amount: payment.amount,
                    memo: payment.notes
                )
            ]
        }

        return JournalEntry(
            id: nil,
            entryNumber: payment.transactionNumber,
            date: payment.date,
            description: "Payment transaction #\(payment.transactionNumber)",
            userId: payment.userId,
            lineItems: lineItems,
            createdAt: nil
        )
    }

    /// Convenience method for creating journal entry from payment with default accounts
    func createJournalEntryFromPayment(
        _ payment: Payment,
        debitAccountId: String,
        creditAccountId: String
    ) -> JournalEntry {
        let accounts = JournalEntryAccounts(
            debitAccountId: debitAccountId,
            debitAccountName: payment.transactionType == .credit
                ? AppConstants.AccountNames.cash
                : AppConstants.AccountNames.accountsReceivable,
            creditAccountId: creditAccountId,
            creditAccountName: payment.transactionType == .credit
                ? AppConstants.AccountNames.accountsReceivable
                : AppConstants.AccountNames.cash
        )
        return createJournalEntry(from: payment, accounts: accounts)
    }
}

// MARK: - Supporting Types

struct JournalEntryAccounts {
    let debitAccountId: String
    let debitAccountName: String
    let creditAccountId: String
    let creditAccountName: String
}

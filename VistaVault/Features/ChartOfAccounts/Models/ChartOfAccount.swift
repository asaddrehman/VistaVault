import Foundation

struct ChartOfAccount: Identifiable, Codable, Hashable {
    var id: String?
    var userId: String
    var accountCode: String
    var accountName: String
    var accountType: AccountType
    var parentAccountId: String?
    var balance: Double
    var isActive: Bool
    var description: String?
    var level: Int // Account hierarchy level

    var createdAt: Date?
    var updatedAt: Date?

    enum AccountType: String, Codable, CaseIterable {
        // Assets (1000-1999)
        case currentAssets = "Current Assets"
        case fixedAssets = "Fixed Assets"
        case otherAssets = "Other Assets"

        // Liabilities (2000-2999)
        case currentLiabilities = "Current Liabilities"
        case longTermLiabilities = "Long-term Liabilities"

        // Equity (3000-3999)
        case ownersEquity = "Owner's Equity"
        case retainedEarnings = "Retained Earnings"

        // Revenue (4000-4999)
        case salesRevenue = "Sales Revenue"
        case serviceRevenue = "Service Revenue"
        case otherRevenue = "Other Revenue"

        // Expenses (5000-5999)
        case operatingExpenses = "Operating Expenses"
        case administrativeExpenses = "Administrative Expenses"
        case sellingExpenses = "Selling Expenses"

        // Cost of Goods Sold (6000-6999)
        case costOfGoodsSold = "Cost of Goods Sold"

        var category: AccountCategory {
            switch self {
            case .currentAssets, .fixedAssets, .otherAssets:
                .asset
            case .currentLiabilities, .longTermLiabilities:
                .liability
            case .ownersEquity, .retainedEarnings:
                .equity
            case .salesRevenue, .serviceRevenue, .otherRevenue:
                .revenue
            case .operatingExpenses, .administrativeExpenses, .sellingExpenses:
                .expense
            case .costOfGoodsSold:
                .cogs
            }
        }

        var codePrefix: String {
            switch category {
            case .asset: "1"
            case .liability: "2"
            case .equity: "3"
            case .revenue: "4"
            case .expense: "5"
            case .cogs: "6"
            }
        }

        var icon: String {
            switch category {
            case .asset: "dollarsign.circle.fill"
            case .liability: "creditcard.fill"
            case .equity: "chart.pie.fill"
            case .revenue: "arrow.down.circle.fill"
            case .expense: "arrow.up.circle.fill"
            case .cogs: "cart.fill"
            }
        }
    }

    enum AccountCategory: String, Codable, Comparable {
        case asset = "Asset"
        case liability = "Liability"
        case equity = "Equity"
        case revenue = "Revenue"
        case expense = "Expense"
        case cogs = "Cost of Goods Sold"

        var normalBalance: BalanceType {
            switch self {
            case .asset, .expense, .cogs:
                .debit
            case .liability, .equity, .revenue:
                .credit
            }
        }

        var sortOrder: Int {
            switch self {
            case .asset: 1
            case .liability: 2
            case .equity: 3
            case .revenue: 4
            case .expense: 5
            case .cogs: 6
            }
        }

        static func < (lhs: AccountCategory, rhs: AccountCategory) -> Bool {
            lhs.sortOrder < rhs.sortOrder
        }
    }

    enum BalanceType: String, Codable {
        case debit = "Debit"
        case credit = "Credit"
    }

    // MARK: - Computed Properties

    var fullAccountNumber: String {
        accountCode
    }

    var normalBalance: BalanceType {
        accountType.category.normalBalance
    }

    var displayBalance: Double {
        switch normalBalance {
        case .debit:
            balance
        case .credit:
            -balance
        }
    }

    // MARK: - CodingKeys

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case accountCode = "account_code"
        case accountName = "account_name"
        case accountType = "account_type"
        case parentAccountId = "parent_account_id"
        case balance
        case isActive = "is_active"
        case description
        case level
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Default Chart of Accounts

extension ChartOfAccount {
    static func defaultAccounts(userId: String) -> [ChartOfAccount] {
        [
            // Assets
            ChartOfAccount(
                id: nil,
                userId: userId,
                accountCode: "1001",
                accountName: "Cash",
                accountType: .currentAssets,
                balance: 0,
                isActive: true,
                level: 1
            ),
            ChartOfAccount(
                id: nil,
                userId: userId,
                accountCode: "1002",
                accountName: "Accounts Receivable",
                accountType: .currentAssets,
                balance: 0,
                isActive: true,
                level: 1
            ),
            ChartOfAccount(
                id: nil,
                userId: userId,
                accountCode: "1003",
                accountName: "Inventory",
                accountType: .currentAssets,
                balance: 0,
                isActive: true,
                level: 1
            ),
            ChartOfAccount(
                id: nil,
                userId: userId,
                accountCode: "1100",
                accountName: "Fixed Assets",
                accountType: .fixedAssets,
                balance: 0,
                isActive: true,
                level: 1
            ),
            ChartOfAccount(
                id: nil,
                userId: userId,
                accountCode: "1101",
                accountName: "Equipment",
                accountType: .fixedAssets,
                balance: 0,
                isActive: true,
                level: 2
            ),

            // Liabilities
            ChartOfAccount(
                id: nil,
                userId: userId,
                accountCode: "2001",
                accountName: "Accounts Payable",
                accountType: .currentLiabilities,
                balance: 0,
                isActive: true,
                level: 1
            ),
            ChartOfAccount(
                id: nil,
                userId: userId,
                accountCode: "2002",
                accountName: "Short-term Loans",
                accountType: .currentLiabilities,
                balance: 0,
                isActive: true,
                level: 1
            ),
            ChartOfAccount(
                id: nil,
                userId: userId,
                accountCode: "2100",
                accountName: "Long-term Debt",
                accountType: .longTermLiabilities,
                balance: 0,
                isActive: true,
                level: 1
            ),

            // Equity
            ChartOfAccount(
                id: nil,
                userId: userId,
                accountCode: "3001",
                accountName: "Owner's Capital",
                accountType: .ownersEquity,
                balance: 0,
                isActive: true,
                level: 1
            ),
            ChartOfAccount(
                id: nil,
                userId: userId,
                accountCode: "3002",
                accountName: "Retained Earnings",
                accountType: .retainedEarnings,
                balance: 0,
                isActive: true,
                level: 1
            ),

            // Revenue
            ChartOfAccount(
                id: nil,
                userId: userId,
                accountCode: "4001",
                accountName: "Sales Revenue",
                accountType: .salesRevenue,
                balance: 0,
                isActive: true,
                level: 1
            ),
            ChartOfAccount(
                id: nil,
                userId: userId,
                accountCode: "4002",
                accountName: "Service Revenue",
                accountType: .serviceRevenue,
                balance: 0,
                isActive: true,
                level: 1
            ),

            // Expenses
            ChartOfAccount(
                id: nil,
                userId: userId,
                accountCode: "5001",
                accountName: "Salaries & Wages",
                accountType: .operatingExpenses,
                balance: 0,
                isActive: true,
                level: 1
            ),
            ChartOfAccount(
                id: nil,
                userId: userId,
                accountCode: "5002",
                accountName: "Rent Expense",
                accountType: .operatingExpenses,
                balance: 0,
                isActive: true,
                level: 1
            ),
            ChartOfAccount(
                id: nil,
                userId: userId,
                accountCode: "5003",
                accountName: "Utilities",
                accountType: .operatingExpenses,
                balance: 0,
                isActive: true,
                level: 1
            ),

            // COGS
            ChartOfAccount(
                id: nil,
                userId: userId,
                accountCode: "6001",
                accountName: "Cost of Goods Sold",
                accountType: .costOfGoodsSold,
                balance: 0,
                isActive: true,
                level: 1
            )
        ]
    }
}

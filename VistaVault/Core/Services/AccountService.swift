import Foundation
import GRDB

@MainActor
class AccountService {
    static let shared = AccountService()
    private let dataController = DataController.shared

    private init() { }

    // MARK: - CRUD Operations

    func fetchAccounts(userId: String) async throws -> [ChartOfAccount] {
        let accountsData = try await dataController.dbQueue.read { db in
            try ChartOfAccountData
                .filter(Column("userId") == userId)
                .order(Column("accountCode"))
                .fetchAll(db)
        }
        return accountsData.map { ChartOfAccount(from: $0, userId: userId) }
    }
    
    func fetchAccount(byId accountId: String) async throws -> ChartOfAccount? {
        guard let userId = LocalAuthManager.shared.currentUserId else {
            throw AppError.authenticationRequired
        }
        
        let accountData = try await dataController.dbQueue.read { db in
            try ChartOfAccountData
                .filter(Column("id") == accountId)
                .fetchOne(db)
        }
        
        guard let accountData = accountData else {
            return nil
        }
        
        return ChartOfAccount(from: accountData, userId: userId)
    }

    func createAccount(_ account: ChartOfAccount) async throws {
        guard !account.userId.isEmpty else {
            throw AppError.requiredFieldMissing("User ID")
        }

        // Fetch user
        guard let _ = try dataController.fetchUser(byId: account.userId) else {
            throw AppError.dataNotFound
        }

        var accountData = account.toData()
        accountData.userId = account.userId

        try await dataController.dbQueue.write { db in
            try accountData.insert(db)
        }
    }

    func updateAccount(_ account: ChartOfAccount) async throws {
        guard let id = account.id else {
            throw AppError.dataNotFound
        }

        try await dataController.dbQueue.write { db in
            guard var accountData = try ChartOfAccountData
                .filter(Column("id") == id)
                .fetchOne(db) else {
                throw AppError.dataNotFound
            }

            // Update properties
            accountData.accountCode = account.accountCode
            accountData.accountName = account.accountName
            accountData.accountTypeRaw = account.accountType.rawValue
            accountData.parentAccountId = account.parentAccountId
            accountData.balance = account.balance
            accountData.isActive = account.isActive
            accountData.accountDescription = account.description
            accountData.level = account.level
            accountData.updatedAt = Date()

            try accountData.update(db)
        }
    }

    func deleteAccount(id: String, balance: Double) async throws {
        // Validate balance is zero
        guard abs(balance) < AppConstants.Accounting.floatingPointTolerance else {
            throw AppError.validationFailed("Cannot delete account with non-zero balance")
        }

        try await dataController.dbQueue.write { db in
            try ChartOfAccountData
                .filter(Column("id") == id)
                .deleteAll(db)
        }
    }

    // MARK: - Business Logic

    func initializeDefaultAccounts(userId: String) async throws {
        let defaultAccounts = ChartOfAccount.defaultAccounts(userId: userId)

        for account in defaultAccounts {
            try await createAccount(account)
        }
    }

    func updateAccountBalance(accountId: String, account: ChartOfAccount, amount: Double, isDebit: Bool) async throws {
        var newBalance = account.balance

        // Update based on normal balance type
        if account.normalBalance == .debit {
            newBalance += isDebit ? amount : -amount
        } else {
            newBalance += isDebit ? -amount : amount
        }

        try await dataController.dbQueue.write { db in
            guard var accountData = try ChartOfAccountData
                .filter(Column("id") == accountId)
                .fetchOne(db) else {
                throw AppError.dataNotFound
            }

            accountData.balance = newBalance
            accountData.updatedAt = Date()
            try accountData.update(db)
        }
    }

    func filterAccounts(
        _ accounts: [ChartOfAccount],
        by category: ChartOfAccount.AccountCategory?
    ) -> [ChartOfAccount] {
        guard let category else { return accounts }
        return accounts.filter { $0.accountType.category == category }
    }

    func searchAccounts(_ accounts: [ChartOfAccount], searchText: String) -> [ChartOfAccount] {
        guard !searchText.isEmpty else { return accounts }

        return accounts.filter { account in
            account.accountName.localizedCaseInsensitiveContains(searchText) ||
                account.accountCode.localizedCaseInsensitiveContains(searchText)
        }
    }

    func validateAccountCode(_ code: String, for type: ChartOfAccount.AccountType) -> Bool {
        let prefix = type.codePrefix
        return code.hasPrefix(prefix)
    }

    func validateAccount(_ account: ChartOfAccount) -> Result<Void, AppError> {
        // Name validation
        guard !account.accountName.trimmingCharacters(in: .whitespaces).isEmpty else {
            return .failure(.requiredFieldMissing("Account name"))
        }

        // Code validation
        guard !account.accountCode.isEmpty else {
            return .failure(.requiredFieldMissing("Account code"))
        }

        // Code format validation
        guard validateAccountCode(account.accountCode, for: account.accountType) else {
            return .failure(.validationFailed("Account code must start with \(account.accountType.codePrefix)"))
        }

        return .success(())
    }
}

import Foundation

@MainActor
class ChartOfAccountsViewModel: ObservableObject {
    @Published var accounts: [ChartOfAccount] = []
    @Published var filteredAccounts: [ChartOfAccount] = []
    @Published var searchText: String = ""
    @Published var selectedCategory: ChartOfAccount.AccountCategory?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let service = AccountService.shared

    // MARK: - Computed Properties

    var assetAccounts: [ChartOfAccount] {
        accounts.filter { $0.accountType.category == .asset }
    }

    var liabilityAccounts: [ChartOfAccount] {
        accounts.filter { $0.accountType.category == .liability }
    }

    var equityAccounts: [ChartOfAccount] {
        accounts.filter { $0.accountType.category == .equity }
    }

    var revenueAccounts: [ChartOfAccount] {
        accounts.filter { $0.accountType.category == .revenue }
    }

    var expenseAccounts: [ChartOfAccount] {
        accounts.filter { $0.accountType.category == .expense }
    }

    var cogsAccounts: [ChartOfAccount] {
        accounts.filter { $0.accountType.category == .cogs }
    }
    
    var cashAndBankAccounts: [ChartOfAccount] {
        accounts.filter { account in
            account.accountType == .currentAssets &&
            (account.accountName.lowercased().contains("cash") ||
             account.accountName.lowercased().contains("bank"))
        }
    }

    // MARK: - Fetch Accounts
    
    func fetchAccounts() {
        guard let userId = LocalAuthManager.shared.currentUserId else { return }
        fetchAccounts(userId: userId)
    }

    func fetchAccounts(userId: String) {
        Task {
            isLoading = true
            errorMessage = nil

            do {
                accounts = try await service.fetchAccounts(userId: userId)
                applyFilters()
            } catch {
                errorMessage = error.localizedDescription
            }

            isLoading = false
        }
    }

    // MARK: - Initialize Default Accounts

    func initializeDefaultAccounts(userId: String) async throws {
        try await service.initializeDefaultAccounts(userId: userId)
        fetchAccounts(userId: userId)
    }

    // MARK: - Create Account

    func createAccount(_ account: ChartOfAccount) async throws {
        // Validate before creating
        let validationResult = service.validateAccount(account)
        switch validationResult {
        case .success:
            try await service.createAccount(account)
            fetchAccounts(userId: account.userId)
        case .failure(let error):
            throw error
        }
    }

    // MARK: - Update Account

    func updateAccount(_ account: ChartOfAccount) async throws {
        // Validate before updating
        let validationResult = service.validateAccount(account)
        switch validationResult {
        case .success:
            try await service.updateAccount(account)
            fetchAccounts(userId: account.userId)
        case .failure(let error):
            throw error
        }
    }

    // MARK: - Delete Account

    func deleteAccount(_ account: ChartOfAccount) async throws {
        guard let id = account.id else {
            throw AppError.dataNotFound
        }

        try await service.deleteAccount(id: id, balance: account.balance)
        fetchAccounts(userId: account.userId)
    }

    // MARK: - Update Account Balance

    func updateAccountBalance(accountId: String, amount: Double, isDebit: Bool) async throws {
        guard let account = getAccount(by: accountId) else {
            throw AppError.dataNotFound
        }

        try await service.updateAccountBalance(accountId: accountId, account: account, amount: amount, isDebit: isDebit)
        fetchAccounts(userId: account.userId)
    }

    // MARK: - Search and Filter

    func applyFilters() {
        var result = service.filterAccounts(accounts, by: selectedCategory)
        result = service.searchAccounts(result, searchText: searchText)
        filteredAccounts = result
    }

    // MARK: - Helper Methods

    func getAccount(by id: String) -> ChartOfAccount? {
        accounts.first { $0.id == id }
    }

    func getAccountByCode(_ code: String) -> ChartOfAccount? {
        accounts.first { $0.accountCode == code }
    }

    func validateAccountCode(_ code: String, for type: ChartOfAccount.AccountType) -> Bool {
        service.validateAccountCode(code, for: type)
    }
}

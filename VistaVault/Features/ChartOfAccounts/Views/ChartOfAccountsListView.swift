import SwiftUI

struct ChartOfAccountsListView: View {
    @StateObject private var viewModel = ChartOfAccountsViewModel()
    @State private var showingAddSheet = false
    @State private var selectedAccount: ChartOfAccount?
    @State private var showInitializeAlert = false

    var body: some View {
        VStack(spacing: 0) {
            categoryPicker
            accountsList
        }
        .navigationTitle("Chart of Accounts")
        .searchable(text: $viewModel.searchText, prompt: "Search accounts...")
        .onChange(of: viewModel.searchText) { _, _ in
            viewModel.applyFilters()
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAddSheet = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            CreateAccountView(viewModel: viewModel)
        }
        .sheet(item: $selectedAccount) { account in
            NavigationStack {
                AccountDetailView(account: account, viewModel: viewModel)
            }
        }
        .alert("Initialize Chart of Accounts", isPresented: $showInitializeAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Initialize") {
                Task {
                    if let userId = LocalAuthManager.shared.currentUserId {
                        try? await viewModel.initializeDefaultAccounts(userId: userId)
                    }
                }
            }
        } message: {
            Text("This will create default accounts for your business. You can customize them later.")
        }
        .onAppear {
            if let userId = LocalAuthManager.shared.currentUserId {
                viewModel.fetchAccounts(userId: userId)
            }
        }
    }

    private var categoryPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppConstants.Spacing.small) {
                CategoryButton(
                    title: "All",
                    isSelected: viewModel.selectedCategory == nil
                ) {
                    viewModel.selectedCategory = nil
                }

                ForEach(accountCategories, id: \.self) { category in
                    CategoryButton(
                        title: category.rawValue,
                        isSelected: viewModel.selectedCategory == category
                    ) {
                        viewModel.selectedCategory = category
                    }
                }
            }
            .padding()
        }
        .onChange(of: viewModel.selectedCategory) { _, _ in
            viewModel.applyFilters()
        }
    }

    private var accountCategories: [ChartOfAccount.AccountCategory] {
        [.asset, .liability, .equity, .revenue, .expense, .cogs]
    }

    private var accountsList: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Loading accounts...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.accounts.isEmpty {
                emptyAccountsView
            } else if viewModel.filteredAccounts.isEmpty {
                noResultsView
            } else {
                accountsListContent
            }
        }
    }

    private var emptyAccountsView: some View {
        ContentUnavailableView(
            "No Accounts",
            systemImage: "list.bullet.rectangle",
            description: Text("Initialize default chart of accounts")
        )
        .overlay(alignment: .bottom) {
            Button("Initialize Default Accounts") {
                showInitializeAlert = true
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }
    }

    private var noResultsView: some View {
        ContentUnavailableView(
            "No Accounts Found",
            systemImage: "magnifyingglass",
            description: Text("Try adjusting your filters")
        )
    }

    private var accountsListContent: some View {
        List {
            ForEach(groupedAccounts.keys.sorted(), id: \.self) { category in
                Section(category.rawValue) {
                    ForEach(groupedAccounts[category] ?? []) { account in
                        Button {
                            selectedAccount = account
                        } label: {
                            AccountRow(account: account)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    private var groupedAccounts: [ChartOfAccount.AccountCategory: [ChartOfAccount]] {
        Dictionary(grouping: viewModel.filteredAccounts) { $0.accountType.category }
    }
}

struct CategoryButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .bold : .regular)
                .padding(.horizontal, AppConstants.Spacing.medium)
                .padding(.vertical, AppConstants.Spacing.small)
                .background(isSelected ? AppConstants.Colors.brandPrimary : Color(.secondarySystemBackground))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(AppConstants.CornerRadius.medium)
        }
    }
}

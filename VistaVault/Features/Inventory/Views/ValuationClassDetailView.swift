import SwiftUI

struct ValuationClassDetailView: View {
    let valuationClass: ValuationClass
    @ObservedObject var viewModel: ValuationClassViewModel
    @StateObject private var accountVM = ChartOfAccountsViewModel()
    @Environment(\.dismiss) var dismiss
    
    @State private var showDeleteAlert = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var inventoryAccount: ChartOfAccount? {
        accountVM.accounts.first { $0.id == valuationClass.inventoryAccountId }
    }
    
    var cogsAccount: ChartOfAccount? {
        accountVM.accounts.first { $0.id == valuationClass.cogsAccountId }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header Card
                headerCard
                
                // GL Accounts Card
                glAccountsCard
                
                // Actions
                actionsSection
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(valuationClass.name)
        .navigationBarTitleDisplayMode(.inline)
        .alert("Delete Valuation Class", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteValuationClass()
            }
        } message: {
            Text("Are you sure you want to delete this valuation class? This action cannot be undone.")
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .onAppear {
            accountVM.fetchAccounts()
        }
    }
    
    private var headerCard: some View {
        VStack(spacing: 12) {
            Image(systemName: "tag.fill")
                .font(.system(size: 60))
                .foregroundColor(AppConstants.Colors.brandPrimary)
            
            Text(valuationClass.name)
                .font(.title2.bold())
                .multilineTextAlignment(.center)
            
            Text(valuationClass.classCode)
                .font(.headline)
                .foregroundColor(.secondary)
            
            if let description = valuationClass.description {
                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 4)
            }
            
            HStack(spacing: 8) {
                if valuationClass.isActive {
                    Text("Active")
                        .font(.subheadline)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.green.opacity(0.1))
                        .foregroundColor(.green)
                        .cornerRadius(8)
                } else {
                    Text("Inactive")
                        .font(.subheadline)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.red.opacity(0.1))
                        .foregroundColor(.red)
                        .cornerRadius(8)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Color(.systemBackground))
        .cornerRadius(AppConstants.CornerRadius.large)
        .shadow(radius: 2)
    }
    
    private var glAccountsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("GL Accounts", systemImage: "list.bullet.clipboard")
                .font(.headline)
            
            if let account = inventoryAccount {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Inventory Account")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(account.accountName)
                                .font(.body)
                            Text(account.accountCode)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Text(account.balance, format: .currency(code: "USD"))
                            .font(.subheadline)
                            .fontWeight(.bold)
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(AppConstants.CornerRadius.medium)
            }
            
            if let account = cogsAccount {
                VStack(alignment: .leading, spacing: 8) {
                    Text("COGS Account")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(account.accountName)
                                .font(.body)
                            Text(account.accountCode)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Text(account.balance, format: .currency(code: "USD"))
                            .font(.subheadline)
                            .fontWeight(.bold)
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(AppConstants.CornerRadius.medium)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(AppConstants.CornerRadius.large)
        .shadow(radius: 2)
    }
    
    private var actionsSection: some View {
        VStack(spacing: 12) {
            Button(action: { showDeleteAlert = true }) {
                Label("Delete Valuation Class", systemImage: "trash")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(AppConstants.CornerRadius.medium)
            }
        }
    }
    
    private func deleteValuationClass() {
        Task {
            do {
                try await viewModel.deleteValuationClass(valuationClass)
                await MainActor.run {
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
}

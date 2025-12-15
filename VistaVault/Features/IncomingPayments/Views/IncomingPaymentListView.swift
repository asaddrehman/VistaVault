import SwiftUI

struct IncomingPaymentListView: View {
    @StateObject private var viewModel = IncomingPaymentViewModel()
    @StateObject private var businessPartnerVM = BusinessPartnerViewModel()
    @State private var showCreatePayment = false
    @State private var searchText = ""
    
    var filteredPayments: [IncomingPayment] {
        if searchText.isEmpty {
            return viewModel.payments
        }
        return viewModel.payments.filter {
            $0.customerName.localizedCaseInsensitiveContains(searchText) ||
            $0.paymentNumber.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading {
                    ProgressView("Loading payments...")
                } else if viewModel.payments.isEmpty {
                    SimpleEmptyStateView(
                        message: "No incoming payments yet",
                        icon: "arrow.down.circle"
                    )
                } else {
                    List {
                        ForEach(filteredPayments) { payment in
                            NavigationLink {
                                IncomingPaymentDetailView(payment: payment, viewModel: viewModel)
                            } label: {
                                IncomingPaymentRow(payment: payment)
                            }
                        }
                        .onDelete(perform: deletePayments)
                    }
                    .searchable(text: $searchText, prompt: "Search payments")
                }
            }
            .navigationTitle("Incoming Payments")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showCreatePayment = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showCreatePayment) {
                CreateIncomingPaymentView(
                    viewModel: viewModel,
                    businessPartnerVM: businessPartnerVM
                )
            }
            .onAppear {
                viewModel.fetchAllPayments()
                if let userId = LocalAuthManager.shared.currentUserId {
                    businessPartnerVM.fetchPartners(userId: userId)
                }
            }
            .refreshable {
                viewModel.fetchAllPayments()
            }
        }
    }
    
    private func deletePayments(at offsets: IndexSet) {
        for index in offsets {
            let payment = filteredPayments[index]
            if let id = payment.id {
                Task {
                    _ = await viewModel.deletePayment(id: id)
                }
            }
        }
    }
}

struct IncomingPaymentRow: View {
    let payment: IncomingPayment
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "arrow.down.circle.fill")
                .font(.title2)
                .foregroundColor(AppConstants.Colors.creditColor)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(payment.customerName)
                    .font(.headline)
                
                Text(payment.paymentNumber)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(payment.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(payment.amount, format: .currency(code: "USD"))
                    .font(.headline)
                    .foregroundColor(AppConstants.Colors.creditColor)
            }
        }
        .padding(.vertical, 4)
    }
}

private struct SimpleEmptyStateView: View {
    let message: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text(message)
                .font(.headline)
                .foregroundColor(.secondary)
        }
    }
}

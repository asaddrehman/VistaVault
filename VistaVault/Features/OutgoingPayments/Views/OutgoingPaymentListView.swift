import SwiftUI

struct OutgoingPaymentListView: View {
    @StateObject private var viewModel = OutgoingPaymentViewModel()
    @StateObject private var businessPartnerVM = BusinessPartnerViewModel()
    @State private var showCreatePayment = false
    @State private var searchText = ""
    
    var filteredPayments: [OutgoingPayment] {
        if searchText.isEmpty {
            return viewModel.payments
        }
        return viewModel.payments.filter {
            $0.vendorName.localizedCaseInsensitiveContains(searchText) ||
            $0.paymentNumber.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading {
                    ProgressView("Loading payments...")
                } else if viewModel.payments.isEmpty {
                    EmptyStateView(
                        title: "No Payments",
                        message: "No outgoing payments yet",
                        icon: "arrow.up.circle"
                    )
                } else {
                    List {
                        ForEach(filteredPayments) { payment in
                            NavigationLink {
                                OutgoingPaymentDetailView(payment: payment, viewModel: viewModel)
                            } label: {
                                OutgoingPaymentRow(payment: payment)
                            }
                        }
                        .onDelete(perform: deletePayments)
                    }
                    .searchable(text: $searchText, prompt: "Search payments")
                }
            }
            .navigationTitle("Outgoing Payments")
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
                CreateOutgoingPaymentView(
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

struct OutgoingPaymentRow: View {
    let payment: OutgoingPayment
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "arrow.up.circle.fill")
                .font(.title2)
                .foregroundColor(AppConstants.Colors.debitColor)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(payment.vendorName)
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
                    .foregroundColor(AppConstants.Colors.debitColor)
            }
        }
        .padding(.vertical, 4)
    }
}

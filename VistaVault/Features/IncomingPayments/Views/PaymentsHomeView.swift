import SwiftUI

struct PaymentsHomeView: View {
    @StateObject private var incomingVM = IncomingPaymentViewModel()
    @StateObject private var outgoingVM = OutgoingPaymentViewModel()
    @StateObject private var businessPartnerVM = BusinessPartnerViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Balance Overview Card
                    SectionCard(title: "Payment Overview", systemImage: "dollarsign.circle.fill") {
                        HStack(spacing: 20) {
                            MetricView(
                                title: "Incoming",
                                value: "\(incomingVM.payments.count)",
                                icon: "arrow.down.circle",
                                gradient: AppConstants.Colors.creditGradient,
                                color: AppConstants.Colors.creditColor
                            )
                            
                            MetricView(
                                title: "Outgoing",
                                value: "\(outgoingVM.payments.count)",
                                icon: "arrow.up.circle",
                                gradient: AppConstants.Colors.debitGradient,
                                color: AppConstants.Colors.debitColor
                            )
                        }
                        .padding(.vertical)
                    }
                    
                    // Quick Actions
                    HStack(spacing: 15) {
                        NavigationLink {
                            IncomingPaymentListView()
                        } label: {
                            QuickActionButton(
                                title: "Incoming",
                                icon: "arrow.down.circle.fill",
                                color: AppConstants.Colors.creditColor
                            )
                        }
                        
                        NavigationLink {
                            OutgoingPaymentListView()
                        } label: {
                            QuickActionButton(
                                title: "Outgoing",
                                icon: "arrow.up.circle.fill",
                                color: AppConstants.Colors.debitColor
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    // Recent Incoming Payments
                    SectionCard(title: "Recent Incoming", systemImage: "arrow.down.circle.fill") {
                        if incomingVM.payments.isEmpty {
                            EmptyStateView(
                                title: "No Payments",
                                message: "No incoming payments",
                                icon: "arrow.down.circle"
                            )
                        } else {
                            ForEach(incomingVM.payments.prefix(5)) { payment in
                                NavigationLink {
                                    IncomingPaymentDetailView(payment: payment, viewModel: incomingVM)
                                } label: {
                                    IncomingPaymentRow(payment: payment)
                                }
                            }
                        }
                    }
                    
                    // Recent Outgoing Payments
                    SectionCard(title: "Recent Outgoing", systemImage: "arrow.up.circle.fill") {
                        if outgoingVM.payments.isEmpty {
                            EmptyStateView(
                                title: "No Payments",
                                message: "No outgoing payments",
                                icon: "arrow.up.circle"
                            )
                        } else {
                            ForEach(outgoingVM.payments.prefix(5)) { payment in
                                NavigationLink {
                                    OutgoingPaymentDetailView(payment: payment, viewModel: outgoingVM)
                                } label: {
                                    OutgoingPaymentRow(payment: payment)
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Payments")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button("Refresh Data") {
                            incomingVM.fetchAllPayments()
                            outgoingVM.fetchAllPayments()
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle.fill")
                    }
                }
            }
            .onAppear {
                if incomingVM.payments.isEmpty {
                    incomingVM.fetchAllPayments(limit: 5)
                }
                if outgoingVM.payments.isEmpty {
                    outgoingVM.fetchAllPayments(limit: 5)
                }
                if let userId = LocalAuthManager.shared.currentUserId {
                    businessPartnerVM.fetchPartners(userId: userId)
                }
            }
        }
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(.white)
            
            Text(title)
                .font(.subheadline.bold())
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color)
        .cornerRadius(AppConstants.CornerRadius.medium)
    }
}

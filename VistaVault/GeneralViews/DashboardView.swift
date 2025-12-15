import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var profileVM: ProfileViewModel
    @StateObject private var businessPartnerVM = BusinessPartnerViewModel()
    @EnvironmentObject var paymentsVM: PaymentsViewModel
    private let brandGradient = LinearGradient(
        gradient: Gradient(colors: [Color.indigo, Color.purple]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    private let metricColors: [Color] = [.blue, .green, .orange, .purple]
    var totalCustomerBalance: Double {
        businessPartnerVM.customers.reduce(0) { $0 + $1.balance }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Company Header
                headerSection
                FinancialOverview
                // Metrics Grid
                metricsGridSection

                // Sales Performance
                salesPerformanceSection
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Dashboard")
        // .refreshable { customerVM.refreshData() }
    }

    // MARK: - Subviews

    private var headerSection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 16) {

                Image(systemName: "building.2.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(brandGradient)
                    .padding(12)
                    .background(Circle().fill(Color(.systemBackground)))
                    .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)

                VStack(alignment: .leading, spacing: 4) {
                    // Text(profileVM.companyProfile.name);

                    // .font(.title2.bold())
                }

                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.secondarySystemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
            )
        }
    }

    private var FinancialOverview: some View {
        VStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Financial Overview")
                    .font(.subheadline)
            }
            .padding()

        }
    }

    // -Metric Grid Section
    private var metricsGridSection: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
            // Row 1: Total Customers
            MetricView(
                title: "Customer Balance",
                value: totalCustomerBalance.sarFormatted(),
                icon: "dollarsign.circle.fill",
                gradient: brandGradient,
                color: .purple
            )

            MetricView(
                title: "Total Transactions",
                value: "\(paymentsVM.payments.count)",
                icon: "doc.text.fill",
                gradient: LinearGradient(colors: [.orange, .yellow], startPoint: .top, endPoint: .bottom),
                color: .orange
            )

            MetricView(
                title: "Total Customers",
                value: "\(businessPartnerVM.customers.count)",
                icon: "person.3.fill",
                gradient: LinearGradient(colors: [.blue, .mint], startPoint: .top, endPoint: .bottom),
                color: .blue
            )

            MetricView(
                title: "Active Customers",
                value: "\(activeCustomersCount)",
                icon: "checkmark.circle.fill",
                gradient: LinearGradient(colors: [.green, .teal], startPoint: .top, endPoint: .bottom),
                color: .purple
            )
        }
    }

    private var salesPerformanceSection: some View {
        SectionCard(title: "Sales Performance", systemImage: "chart.line.uptrend.xyaxis") {
            VStack(spacing: 16) {
                salesChartPlaceholder

                HStack {
                    VStack(alignment: .leading) {
                        Text("30d Change")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Text("+12.4%")
                            .font(.title3.weight(.bold))
                            .foregroundColor(.green)
                    }

                    Spacer()

                    VStack(alignment: .trailing) {
                        Text("Last Month")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Text("₱0.00")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(brandGradient)
                    }
                }
            }
            .padding(.vertical)
        }
    }

    // -
    private func iconWithBackground(systemName: String, color: Color) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(color.opacity(0.2))
                .frame(width: 40, height: 40)

            Image(systemName: systemName)
                .font(.title2)
                .foregroundColor(color)
        }
    }

    // MARK: - Computed Properties

    private var activeCustomersCount: Int {
        businessPartnerVM.customers.filter { $0.balance != 0 }.count
    }

    private var activeCustomerPercentage: Double {
        guard !businessPartnerVM.customers.isEmpty else { return 0 }
        return Double(activeCustomersCount) / Double(businessPartnerVM.customers.count)
    }

    private var averageBalance: Double {
        guard !businessPartnerVM.customers.isEmpty else { return 0 }
        return totalCustomerBalance / Double(businessPartnerVM.customers.count)
    }

    private var salesChartPlaceholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
                .frame(height: 150)

            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 40))
                .foregroundStyle(brandGradient.opacity(0.3))
        }
    }
}

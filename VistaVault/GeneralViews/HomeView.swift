import SwiftUI

struct HomeView: View {
    @StateObject var authManager = LocalAuthManager.shared
    @StateObject var profileVM = ProfileViewModel()
    @StateObject private var invoiceVM = InvoiceViewModel()
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            // Accounts Tab
            NavigationStack {
                ChartOfAccountsListView()
                    .navigationTitle("Accounts")
                    .environmentObject(profileVM)
                    .background(Color(.systemBackground))
            }
            .tabItem {
                Image(systemName: "chart.bar.doc.horizontal")
                Text("Accounts")
            }
            .tag(0)

            // Payments Tab
            NavigationStack {
                PaymentsHomeView()
                    .navigationTitle("Payments")
            }
            .tabItem {
                Image(systemName: "dollarsign.circle.fill")
                Text("Payments")
            }
            .tag(1)

            // Menu Tab
            NavigationStack {
                MenuView()
            }
            .tabItem {
                Image(systemName: "menucard.fill")
                Text("More")
            }
            .tag(2)

            // Profile Tab
            NavigationStack {
                ProfileView()
                    .environmentObject(authManager)
                    .environmentObject(profileVM)
            }
            .tabItem {
                Image(systemName: "person.crop.circle.fill")
                Text("Profile")
            }
            .tag(3)
        }
        .tint(AppConstants.Colors.brandPrimary)
        .background(Color(.systemBackground))
        .onAppear {
            setupTabBarAppearance()
            setupGlobalAppearance()
        }
    }

    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
        UITabBar.appearance().scrollEdgeAppearance = appearance
        UITabBar.appearance().standardAppearance = appearance
    }

    private func setupGlobalAppearance() {
        let navigationAppearance = UINavigationBarAppearance()
        navigationAppearance.configureWithOpaqueBackground()
        navigationAppearance.backgroundColor = UIColor.systemBackground

        UINavigationBar.appearance().standardAppearance = navigationAppearance
        UINavigationBar.appearance().compactAppearance = navigationAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationAppearance

        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor.systemBackground

        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }
}

struct MenuView: View {
    var body: some View {
        List {
            // Accounting Section
            Section("Accounting") {
                NavigationLink {
                    ChartOfAccountsListView()
                        .navigationTitle("Chart of Accounts")
                } label: {
                    Label("Chart of Accounts", systemImage: "list.bullet.rectangle")
                }

                NavigationLink {
                    JournalEntryListView()
                        .navigationTitle("Journal Entries")
                } label: {
                    Label("Journal Entries", systemImage: "book.closed")
                }
            }

            // Business Partners Section
            Section("Business Partners") {
                NavigationLink {
                    BusinessPartnerListView()
                        .navigationTitle("Business Partners")
                } label: {
                    Label("Business Partners", systemImage: "person.2.fill")
                }
            }

            // Transactions Section
            Section("Transactions") {
                NavigationLink {
                    IncomingPaymentListView()
                        .navigationTitle("Incoming Payments")
                } label: {
                    Label("Incoming Payments", systemImage: "arrow.down.circle.fill")
                }
                
                NavigationLink {
                    OutgoingPaymentListView()
                        .navigationTitle("Outgoing Payments")
                } label: {
                    Label("Outgoing Payments", systemImage: "arrow.up.circle.fill")
                }
                
                NavigationLink {
                    // Sales view to be implemented
                    Text("Sales & Invoices")
                        .navigationTitle("Sales")
                } label: {
                    Label("Sales & Invoices", systemImage: "cart.fill")
                }

                NavigationLink {
                    // Purchases view to be implemented
                    Text("Purchases")
                        .navigationTitle("Purchases")
                } label: {
                    Label("Purchases", systemImage: "shippingbox.fill")
                }
            }

            // Inventory Section
            Section("Inventory") {
                NavigationLink {
                    InventoryView()
                        .navigationTitle("Inventory")
                } label: {
                    Label("Inventory Items", systemImage: "cube.box.fill")
                }
            }

            // Reports Section
            Section("Reports & Analytics") {
                NavigationLink {
                    ReportsView()
                        .navigationTitle("Transaction Reports")
                } label: {
                    Label("Transaction Reports", systemImage: "chart.bar.doc.horizontal")
                }

                NavigationLink {
                    // Financial statements to be implemented
                    Text("Financial Statements")
                        .navigationTitle("Financial Statements")
                } label: {
                    Label("Financial Statements", systemImage: "doc.text.magnifyingglass")
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Menu")
    }
}

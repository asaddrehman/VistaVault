//
//  ReportFilters.swift
//  ValueVault
//
//  Created by Asad ur Rehman on 30/10/1446 AH.
//
import SwiftUI

struct ReportFilters {
    var transactionType: TransactionTypeFilter = .all
    var startDate: Date = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
    var endDate: Date = .init()
    var selectedCustomer: Customer?
}

enum TransactionTypeFilter: String, CaseIterable {
    case all = "All"
    case credit = "Credit"
    case debit = "Debit"
}

// Reports View
struct ReportsView: View {
    @StateObject private var viewModel = ReportsViewModel()
    @State private var showFilters = true
    @State private var showCustomerPicker = false

    var body: some View {
        NavigationStack {
            VStack {
                if showFilters {
                    Form {
                        // Transaction Type Filter
                        Section("Transaction Type") {
                            Picker("Type", selection: $viewModel.filters.transactionType) {
                                ForEach(TransactionTypeFilter.allCases, id: \.self) { type in
                                    Text(type.rawValue).tag(type)
                                }
                            }
                            .pickerStyle(.segmented)
                        }

                        // Date Range Filter
                        Section("Date Range") {
                            DatePicker("From", selection: $viewModel.filters.startDate, displayedComponents: .date)
                            DatePicker("To", selection: $viewModel.filters.endDate, displayedComponents: .date)
                        }

                        // Customer Filter
                        Section("Customer") {
                            HStack {
                                if let customer = viewModel.filters.selectedCustomer {
                                    Text(customer.displayName)
                                    Spacer()
                                    Button("Clear") {
                                        viewModel.filters.selectedCustomer = nil
                                    }
                                } else {
                                    Text("All Customers")
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Button("Select") {
                                        showCustomerPicker = true
                                    }
                                }
                            }
                        }
                    }
                    .frame(maxHeight: 300)

                    // Generate Report Button
                    Button(action: viewModel.generateReport) {
                        Text("Generate Report")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()
                }

                // Report Results
                if viewModel.isLoading {
                    ProgressView()
                } else if !viewModel.filteredPayments.isEmpty {
                    List(viewModel.filteredPayments) { payment in
                        ReportRow(
                            payment: payment,
                            customerName: viewModel.businessPartnerVM.getPartner(by: payment.customerId)?
                                .displayName ?? "Unknown"
                        )
                    }
                } else {
                    ContentUnavailableView(
                        "No Transactions",
                        systemImage: "doc.text.magnifyingglass",
                        description: Text("No transactions found for selected filters")
                    )
                }
            }
            .navigationTitle("Transaction Report")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(showFilters ? "Hide Filters" : "Show Filters") {
                        withAnimation {
                            showFilters.toggle()
                        }
                    }
                }
            }
            .sheet(isPresented: $showCustomerPicker) {
                CustomerSelectionView(
                    customers: viewModel.businessPartnerVM.customers,
                    selectedCustomer: $viewModel.filters.selectedCustomer
                )
            }
        }
    }
}

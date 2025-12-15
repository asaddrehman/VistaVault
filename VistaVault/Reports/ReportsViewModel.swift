//
//  ReportsViewModel.swift
//  ValueVault
//
//  Created by Asad ur Rehman on 30/10/1446 AH.
//
import Foundation

@MainActor
class ReportsViewModel: ObservableObject {
    @Published var filters = ReportFilters()
    @Published var filteredPayments = [Payment]()
    @Published var isLoading = false

    let paymentsVM = PaymentsViewModel()
    let businessPartnerVM = BusinessPartnerViewModel()

    private let authManager = LocalAuthManager.shared

    init() {
        paymentsVM.fetchAllPayments()
        if let userId = authManager.currentUserId {
            businessPartnerVM.fetchPartners(userId: userId)
        }
    }

    func generateReport() {
        isLoading = true
        defer { isLoading = false }

        // Apply filters
        filteredPayments = paymentsVM.payments.filter { payment in
            // Date Filter
            guard payment.date >= filters.startDate, payment.date <= filters.endDate else {
                return false
            }

            // Transaction Type Filter
            switch filters.transactionType {
            case .credit:
                if payment.transactionType != .credit {
                    return false
                }
            case .debit:
                if payment.transactionType != .debit {
                    return false
                }
            case .all:
                break
            }

            // Customer Filter
            if let selectedCustomer = filters.selectedCustomer {
                return payment.customerId == selectedCustomer.id
            }

            return true
        }
    }
}

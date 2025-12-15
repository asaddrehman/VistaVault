import Combine
import Foundation

@MainActor
class PaymentsViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var payments = [Payment]()
    @Published var isLoading = false
    @Published var errorMessage = ""
    
    // MARK: - Dependencies
    
    private let incomingPaymentService = IncomingPaymentService.shared
    private let outgoingPaymentService = OutgoingPaymentService.shared
    private let authManager = LocalAuthManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init() { }
    
    // MARK: - Payment Fetching
    
    func fetchAllPayments() {
        isLoading = true
        
        Task {
            do {
                let incomingPayments = try await incomingPaymentService.fetchAllIncomingPayments()
                let outgoingPayments = try await outgoingPaymentService.fetchAllOutgoingPayments()
                
                let allPayments = incomingPayments.map { Payment(from: $0) } + 
                                 outgoingPayments.map { Payment(from: $0) }
                
                await MainActor.run {
                    self.payments = allPayments.sorted { $0.date > $1.date }
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    handleError("Payments fetch failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func fetchPayments(customerId: String) {
        isLoading = true
        
        Task {
            do {
                let incomingPayments = try await incomingPaymentService.fetchIncomingPayments(forCustomerId: customerId)
                let outgoingPayments = try await outgoingPaymentService.fetchOutgoingPayments(forVendorId: customerId)
                
                let allPayments = incomingPayments.map { Payment(from: $0) } + 
                                 outgoingPayments.map { Payment(from: $0) }
                
                await MainActor.run {
                    self.payments = allPayments.sorted { $0.date > $1.date }
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    handleError("Payments fetch failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Filtering
    
    func filterPayments(startDate: Date, endDate: Date, customerId: String?) {
        isLoading = true
        
        Task {
            do {
                var incomingPayments: [IncomingPayment]
                var outgoingPayments: [OutgoingPayment]
                
                if let customerId = customerId {
                    incomingPayments = try await incomingPaymentService.fetchIncomingPayments(forCustomerId: customerId)
                    outgoingPayments = try await outgoingPaymentService.fetchOutgoingPayments(forVendorId: customerId)
                } else {
                    incomingPayments = try await incomingPaymentService.fetchAllIncomingPayments()
                    outgoingPayments = try await outgoingPaymentService.fetchAllOutgoingPayments()
                }
                
                let filteredIncoming = incomingPayments.filter { payment in
                    payment.date >= startDate && payment.date <= endDate
                }
                
                let filteredOutgoing = outgoingPayments.filter { payment in
                    payment.date >= startDate && payment.date <= endDate
                }
                
                let allPayments = filteredIncoming.map { Payment(from: $0) } + 
                                 filteredOutgoing.map { Payment(from: $0) }
                
                await MainActor.run {
                    self.payments = allPayments.sorted { $0.date > $1.date }
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    handleError("Filter error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    func handleError(_ message: String) {
        errorMessage = message
        isLoading = false
    }
}

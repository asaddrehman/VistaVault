import Combine
import Foundation

@MainActor
class IncomingPaymentViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var payments = [IncomingPayment]()
    @Published var isLoading = false
    @Published var errorMessage = ""
    
    // MARK: - Dependencies
    
    private let paymentService = IncomingPaymentService.shared
    private let authManager = LocalAuthManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init() { }
    
    // MARK: - Payment Processing
    
    struct PaymentParams {
        let customerId: String
        let customerName: String
        let receivedInAccountId: String
        let amount: Double
        let date: Date
        let notes: String?
        let referenceNumber: String?
    }
    
    func createPayment(_ params: PaymentParams) async -> Result<Void, Error> {
        guard authManager.currentUserId != nil else {
            return .failure(NSError(domain: "Auth", code: 401))
        }
        
        guard params.amount > 0 else {
            return .failure(NSError(
                domain: "Payment",
                code: 400,
                userInfo: [NSLocalizedDescriptionKey: "Invalid amount"]
            ))
        }
        
        do {
            let paymentNumber = try await paymentService.generatePaymentNumber()
            let payment = IncomingPayment(
                paymentNumber: paymentNumber,
                amount: params.amount,
                date: params.date,
                customerId: params.customerId,
                customerName: params.customerName,
                receivedInAccountId: params.receivedInAccountId,
                userId: authManager.currentUserId ?? "",
                notes: params.notes,
                referenceNumber: params.referenceNumber,
                createdAt: Date()
            )
            
            try await paymentService.createIncomingPayment(payment)
            return .success(())
        } catch {
            return .failure(error)
        }
    }
    
    // MARK: - Payment Fetching
    
    func fetchPayments(customerId: String? = nil) {
        isLoading = true
        
        Task {
            do {
                let fetchedPayments: [IncomingPayment]
                if let customerId = customerId {
                    fetchedPayments = try await paymentService.fetchIncomingPayments(forCustomerId: customerId)
                } else {
                    fetchedPayments = try await paymentService.fetchAllIncomingPayments()
                }
                
                await MainActor.run {
                    self.payments = fetchedPayments
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    handleError("Payments fetch failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func fetchAllPayments(limit: Int = 100) {
        isLoading = true
        
        Task {
            do {
                let fetchedPayments = try await paymentService.fetchAllIncomingPayments()
                await MainActor.run {
                    self.payments = Array(fetchedPayments.prefix(limit))
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
                let fetchedPayments: [IncomingPayment]
                if let customerId = customerId {
                    fetchedPayments = try await paymentService.fetchIncomingPayments(forCustomerId: customerId)
                        .filter { payment in
                            payment.date >= startDate && payment.date <= endDate
                        }
                } else {
                    fetchedPayments = try await paymentService.fetchAllIncomingPayments()
                        .filter { payment in
                            payment.date >= startDate && payment.date <= endDate
                        }
                }
                
                await MainActor.run {
                    self.payments = fetchedPayments
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    handleError("Filter error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Deletion
    
    func deletePayment(id: String) async -> Result<Void, Error> {
        do {
            try await paymentService.deleteIncomingPayment(id: id)
            await MainActor.run {
                payments.removeAll { $0.id == id }
            }
            return .success(())
        } catch {
            return .failure(error)
        }
    }
    
    // MARK: - Helpers
    
    func handleError(_ message: String) {
        errorMessage = message
        isLoading = false
    }
}

import Combine
import Foundation

@MainActor
class OutgoingPaymentViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var payments = [OutgoingPayment]()
    @Published var isLoading = false
    @Published var errorMessage = ""
    
    // MARK: - Dependencies
    
    private let paymentService = OutgoingPaymentService.shared
    private let authManager = LocalAuthManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init() { }
    
    // MARK: - Payment Processing
    
    struct PaymentParams {
        let vendorId: String
        let vendorName: String
        let paidFromAccountId: String
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
            let payment = OutgoingPayment(
                paymentNumber: paymentNumber,
                amount: params.amount,
                date: params.date,
                vendorId: params.vendorId,
                vendorName: params.vendorName,
                paidFromAccountId: params.paidFromAccountId,
                userId: authManager.currentUserId ?? "",
                notes: params.notes,
                referenceNumber: params.referenceNumber,
                createdAt: Date()
            )
            
            try await paymentService.createOutgoingPayment(payment)
            return .success(())
        } catch {
            return .failure(error)
        }
    }
    
    // MARK: - Payment Fetching
    
    func fetchPayments(vendorId: String? = nil) {
        isLoading = true
        
        Task {
            do {
                let fetchedPayments: [OutgoingPayment]
                if let vendorId = vendorId {
                    fetchedPayments = try await paymentService.fetchOutgoingPayments(forVendorId: vendorId)
                } else {
                    fetchedPayments = try await paymentService.fetchAllOutgoingPayments()
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
                let fetchedPayments = try await paymentService.fetchAllOutgoingPayments()
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
    
    func filterPayments(startDate: Date, endDate: Date, vendorId: String?) {
        isLoading = true
        
        Task {
            do {
                let fetchedPayments: [OutgoingPayment]
                if let vendorId = vendorId {
                    fetchedPayments = try await paymentService.fetchOutgoingPayments(forVendorId: vendorId)
                        .filter { payment in
                            payment.date >= startDate && payment.date <= endDate
                        }
                } else {
                    fetchedPayments = try await paymentService.fetchAllOutgoingPayments()
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
            try await paymentService.deleteOutgoingPayment(id: id)
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

import SwiftUI

struct IncomingPaymentDetailView: View {
    let payment: IncomingPayment
    @ObservedObject var viewModel: IncomingPaymentViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showDeleteAlert = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header Card
                VStack(spacing: 12) {
                    Image(systemName: "arrow.down.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(AppConstants.Colors.creditColor)
                    
                    Text(payment.amount, format: .currency(code: "USD"))
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(AppConstants.Colors.creditColor)
                    
                    Text(payment.paymentNumber)
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .background(Color(.systemBackground))
                .cornerRadius(AppConstants.CornerRadius.large)
                .shadow(radius: 2)
                
                // Details Card
                VStack(alignment: .leading, spacing: 16) {
                    DetailRow(label: "Customer", value: payment.customerName, icon: "person.fill")
                    Divider()
                    DetailRow(label: "Date", value: payment.date.formatted(date: .long, time: .omitted), icon: "calendar")
                    Divider()
                    DetailRow(label: "Payment Number", value: payment.paymentNumber, icon: "number")
                    
                    if let reference = payment.referenceNumber {
                        Divider()
                        DetailRow(label: "Reference", value: reference, icon: "number.circle")
                    }
                    
                    if let notes = payment.notes {
                        Divider()
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Notes", systemImage: "note.text")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(notes)
                                .font(.body)
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(AppConstants.CornerRadius.large)
                .shadow(radius: 2)
                
                // Delete Button
                Button(action: { showDeleteAlert = true }) {
                    Label("Delete Payment", systemImage: "trash")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(AppConstants.CornerRadius.medium)
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Payment Details")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Delete Payment", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deletePayment()
            }
        } message: {
            Text("Are you sure you want to delete this payment? This action cannot be undone.")
        }
    }
    
    private func deletePayment() {
        guard let id = payment.id else { return }
        
        Task {
            let result = await viewModel.deletePayment(id: id)
            
            await MainActor.run {
                if case .success = result {
                    dismiss()
                }
            }
        }
    }
}

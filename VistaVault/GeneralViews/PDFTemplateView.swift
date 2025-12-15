import SwiftUI

struct PDFTemplateView: View {
    let payment: Payment
    let customer: Customer

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HeaderSection(payment: payment, customer: customer)

            VStack(spacing: 8) {
                PDFDetailRow(title: "Date:", value: payment.date.formatted(date: .numeric, time: .omitted))
                PDFDetailRow(title: "Type:", value: payment.transactionType.rawValue.capitalized)
                PDFDetailRow(title: "Amount:", value: payment.amount.sarFormatted())
                    .foregroundColor(payment.transactionType == .credit ? .green : .red)
                PDFDetailRow(title: "Net Balance:", value: customer.balance.sarFormatted())
            }
            .padding(.vertical)

            CustomerDetailsSection(customer: customer)

            if let notes = payment.notes, !notes.isEmpty {
                NotesSection(notes: notes)
            }

            Spacer()

            FooterSection()
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .drawingGroup() // Ensure proper rendering
    }
}

// Subviews for better organization
struct HeaderSection: View {
    let payment: Payment
    let customer: Customer

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                Text("Transaction Receipt")
                    .font(.system(size: 24, weight: .bold))
                Text("#\(payment.transactionNumber)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            Spacer()

            VStack(alignment: .trailing) {
                Text(customer.displayName)
                    .font(.headline)
                if let address = customer.formattedAddress {
                    Text(address)
                        .font(.caption)
                }
            }
        }
        .padding(.bottom, 20)
    }
}

struct CustomerDetailsSection: View {
    let customer: Customer

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Customer Details")
                .font(.headline)
                .padding(.bottom, 4)

            if let phone = customer.phone {
                PDFDetailRow(title: "Phone:", value: phone)
            }
            if let taxId = customer.taxId {
                PDFDetailRow(title: "Tax ID:", value: taxId)
            }
            if let email = customer.email {
                PDFDetailRow(title: "Email:", value: email)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

struct NotesSection: View {
    let notes: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Notes:")
                .font(.headline)
            Text(notes)
                .font(.body)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

struct FooterSection: View {
    var body: some View {
        Text("Generated on \(Date().formatted(date: .abbreviated, time: .shortened))")
            .font(.caption)
            .foregroundColor(.gray)
    }
}

// Simple DetailRow for PDF template
private struct PDFDetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.body)
                .foregroundColor(.primary)
        }
    }
}

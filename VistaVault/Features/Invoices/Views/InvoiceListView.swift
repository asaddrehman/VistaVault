import SwiftUI

struct InvoiceListView: View {
    @ObservedObject var vm: InvoiceViewModel
    @StateObject private var businessPartnerVM = BusinessPartnerViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if vm.invoices.isEmpty {
                    ContentUnavailableView(
                        "No Invoices",
                        systemImage: "doc.text",
                        description: Text("Create your first invoice using the + button")
                    )
                } else {
                    List(vm.invoices) { invoice in
                        NavigationLink {
                            InvoiceDetailView(invoice: invoice)
                        } label: {
                            InvoiceRow(invoice: invoice)
                        }
                    }
                }
            }
            .navigationTitle("Invoices")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        InvoiceCreationView(
                            vm: InvoiceViewModel(),
                            businessPartnerVM: businessPartnerVM,
                            inventoryVM: InventoryViewModel()
                        )
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .onAppear {
                vm.fetchInvoices()
            }
        }
    }
}

struct InvoiceRow: View {
    let invoice: Invoice

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(invoice.invoiceNumber)
                    .font(.headline)

                Text(invoice.customerName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing) {
                Text(invoice.totalAmount.sarFormatted())
                    .font(.headline)

                Text(invoice.invoiceDate.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}

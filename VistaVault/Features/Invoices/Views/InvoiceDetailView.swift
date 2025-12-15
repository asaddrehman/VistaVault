//
//  InvoiceDetailView.swift
//  VistaVault
//
//  Created by Asad ur Rehman on 05/11/1446 AH.
//
import SwiftUI

struct InvoiceDetailView: View {
    let invoice: Invoice
    @StateObject private var businessPartnerVM = BusinessPartnerViewModel()
    @EnvironmentObject var pdfService: PDFExportService
    @Environment(\.dismiss) var dismiss
    @State private var pdfURL: URL?
    @State private var showPDFSheet = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var customer: Customer?

    var body: some View {
        List {
            // Header Section
            Section {
                VStack(alignment: .leading) {
                    Text("Invoice #\(invoice.invoiceNumber)")
                        .font(.title2.bold())

                    Text(invoice.invoiceDate.formatted(date: .abbreviated, time: .shortened))
                        .foregroundColor(.secondary)
                }
            }

            // Customer Section
            Section {
                if let customer {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(customer.displayName)
                            .font(.headline)

                        if let address = customer.formattedAddress {
                            Text(address)
                        }

                        if let phone = customer.phone {
                            Text(phone)
                        }
                    }
                } else {
                    ProgressView()
                }
            } header: {
                Text("Bill To")
            }

            // Items Section
            Section {
                ForEach(invoice.items) { item in
                    HStack {
                        Text(item.name)

                        Spacer()

                        Text("\(item.quantity) × \(item.unitPrice.sarFormatted())")
                            .foregroundColor(.secondary)

                        Text(item.totalPrice.sarFormatted())
                            .frame(width: 80, alignment: .trailing)
                    }
                }
            } header: {
                Text("Items")
            }

            // Total Section
            Section {
                HStack {
                    Text("Total")
                    Spacer()
                    Text(invoice.totalAmount.sarFormatted())
                        .font(.headline.bold())
                }
            }

            // Dates Section
            Section {
                HStack {
                    Text("Invoice Date")
                    Spacer()
                    Text(invoice.invoiceDate.formatted(date: .numeric, time: .omitted))
                }

                if let created = invoice.createdAt {
                    HStack {
                        Text("Created At")
                        Spacer()
                        Text(created.formatted())
                    }
                }
            }
        }
        .navigationTitle("Invoice Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: exportPDF) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .sheet(isPresented: $showPDFSheet) {
            if let url = pdfURL {
                ActivityView(activityItems: [url])
            }
        }
        .alert("Export Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .onAppear {
            fetchCustomer()
        }
    }

    private func fetchCustomer() {
        if let partner = businessPartnerVM.getPartner(by: invoice.customerId) {
            customer = partner
        } else {
            errorMessage = "Customer not found"
            showError = true
        }
    }

    private func exportPDF() {
        Task {
            guard let customer else { return }

            let result = await pdfService.exportInvoice(invoice, customer: customer)

            switch result {
            case .success(let url):
                await MainActor.run {
                    pdfURL = url
                    showPDFSheet = true
                }
            case .failure(let error):
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
}

import SwiftUI

class PDFExportService: ObservableObject {
    func exportTransaction(_ payment: Payment, customer: Customer) async -> Result<URL, Error> {
        await withCheckedContinuation { continuation in
            // Create PDF data container
            let pdfData = NSMutableData()
            let pageRect = CGRect(x: 0, y: 0, width: 595.2, height: 841.8) // A4 size

            // Perform UI work on main actor
            Task { @MainActor in
                do {
                    // PDF Context Setup
                    UIGraphicsBeginPDFContextToData(pdfData, pageRect, nil)
                    guard let context = UIGraphicsGetCurrentContext() else {
                        throw NSError(
                            domain: "PDFError",
                            code: -1,
                            userInfo: [NSLocalizedDescriptionKey: "Failed to create PDF context"]
                        )
                    }

                    UIGraphicsBeginPDFPage()

                    // Create PDF View
                    let pdfView = PDFTemplateView(payment: payment, customer: customer)
                        .frame(width: pageRect.width, height: pageRect.height)

                    // Render Content
                    let renderer = ImageRenderer(content: pdfView)
                    renderer.render { _, renderer in
                        context.saveGState()
                        defer { context.restoreGState() }

                        // Coordinate System Transform
                        context.translateBy(x: 0, y: pageRect.height)
                        context.scaleBy(x: 1.0, y: -1.0)

                        renderer(context)
                    }

                    UIGraphicsEndPDFContext()

                    // Write to file on background thread
                    DispatchQueue.global(qos: .userInitiated).async { [pdfData] in
                        do {
                            let tempURL = FileManager.default.temporaryDirectory
                                .appendingPathComponent("\(payment.transactionNumber).pdf")

                            try pdfData.write(to: tempURL, options: .atomic)
                            continuation.resume(returning: .success(tempURL))
                        } catch {
                            continuation.resume(returning: .failure(error))
                        }
                    }
                } catch {
                    continuation.resume(returning: .failure(error))
                }
            }
        }
    }
}

extension PDFExportService {
    func exportInvoice(_: Invoice, customer _: Customer) async -> Result<URL, Error> {
        // Implement your PDF generation logic here
        // This should create a PDF with invoice details
        // Return temporary file URL
        .failure(NSError(domain: "PDF", code: 501))
    }
}

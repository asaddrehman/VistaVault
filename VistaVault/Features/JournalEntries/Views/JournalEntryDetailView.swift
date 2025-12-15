import SwiftUI

struct JournalEntryDetailView: View {
    let entry: JournalEntry
    @ObservedObject var viewModel: JournalEntryViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showDeleteAlert = false
    
    var totalDebits: Double {
        entry.lineItems.filter { $0.type == .debit }.reduce(0) { $0 + $1.amount }
    }
    
    var totalCredits: Double {
        entry.lineItems.filter { $0.type == .credit }.reduce(0) { $0 + $1.amount }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header Card
                VStack(spacing: 12) {
                    Image(systemName: entry.isBalanced ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(entry.isBalanced ? .green : .orange)
                    
                    Text(entry.entryNumber)
                        .font(.title.bold())
                    
                    Text(entry.date.formatted(date: .long, time: .omitted))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    if !entry.isBalanced {
                        Text("⚠️ Entry is not balanced")
                            .font(.caption)
                            .foregroundColor(.orange)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .background(Color(.systemBackground))
                .cornerRadius(AppConstants.CornerRadius.large)
                .shadow(radius: 2)
                
                // Description Card
                if !entry.description.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Description", systemImage: "note.text")
                            .font(.headline)
                        
                        Text(entry.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(AppConstants.CornerRadius.large)
                    .shadow(radius: 2)
                }
                
                // Totals Summary Card
                HStack(spacing: 20) {
                    VStack(spacing: 8) {
                        Text("Total Debits")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(totalDebits, format: .currency(code: "USD"))
                            .font(.title3.bold())
                            .foregroundColor(AppConstants.Colors.debitColor)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(AppConstants.CornerRadius.medium)
                    
                    VStack(spacing: 8) {
                        Text("Total Credits")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(totalCredits, format: .currency(code: "USD"))
                            .font(.title3.bold())
                            .foregroundColor(AppConstants.Colors.creditColor)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(AppConstants.CornerRadius.medium)
                }
                .shadow(radius: 2)
                
                // Line Items Card
                VStack(alignment: .leading, spacing: 16) {
                    Label("Line Items", systemImage: "list.bullet")
                        .font(.headline)
                    
                    ForEach(entry.lineItems) { lineItem in
                        JournalLineItemRow(lineItem: lineItem)
                        
                        if lineItem.id != entry.lineItems.last?.id {
                            Divider()
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(AppConstants.CornerRadius.large)
                .shadow(radius: 2)
                
                // Delete Button
                Button(action: { showDeleteAlert = true }) {
                    Label("Delete Journal Entry", systemImage: "trash")
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
        .navigationTitle("Journal Entry")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Delete Journal Entry", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteEntry()
            }
        } message: {
            Text("Are you sure you want to delete this journal entry? This action cannot be undone.")
        }
    }
    
    private func deleteEntry() {
        guard let id = entry.id else { return }
        
        Task {
            let result = await viewModel.deleteJournalEntry(id: id)
            
            await MainActor.run {
                if case .success = result {
                    dismiss()
                }
            }
        }
    }
}

struct JournalLineItemRow: View {
    let lineItem: JournalLineItem
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Type indicator
            Image(systemName: lineItem.type == .debit ? "minus.circle.fill" : "plus.circle.fill")
                .font(.title3)
                .foregroundColor(lineItem.type == .debit ? AppConstants.Colors.debitColor : AppConstants.Colors.creditColor)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(lineItem.accountName)
                    .font(.headline)
                
                Text(lineItem.type.rawValue)
                    .font(.caption)
                    .foregroundColor(lineItem.type == .debit ? AppConstants.Colors.debitColor : AppConstants.Colors.creditColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(
                        (lineItem.type == .debit ? AppConstants.Colors.debitColor : AppConstants.Colors.creditColor)
                            .opacity(0.1)
                    )
                    .cornerRadius(4)
                
                if let memo = lineItem.memo, !memo.isEmpty {
                    Text(memo)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 2)
                }
            }
            
            Spacer()
            
            Text(lineItem.amount, format: .currency(code: "USD"))
                .font(.headline)
                .foregroundColor(lineItem.type == .debit ? AppConstants.Colors.debitColor : AppConstants.Colors.creditColor)
        }
    }
}

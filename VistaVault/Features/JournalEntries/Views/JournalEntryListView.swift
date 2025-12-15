import SwiftUI

struct JournalEntryListView: View {
    @StateObject private var viewModel = JournalEntryViewModel()
    @State private var showCreateEntry = false
    @State private var searchText = ""
    
    var filteredEntries: [JournalEntry] {
        if searchText.isEmpty {
            return viewModel.journalEntries
        }
        return viewModel.journalEntries.filter {
            $0.entryNumber.localizedCaseInsensitiveContains(searchText) ||
            $0.description.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading {
                    ProgressView("Loading journal entries...")
                } else if viewModel.journalEntries.isEmpty {
                    EmptyStateView(
                        title: "No Entries",
                        message: "No journal entries yet",
                        icon: "book.closed"
                    )
                } else {
                    List {
                        ForEach(filteredEntries) { entry in
                            NavigationLink {
                                JournalEntryDetailView(entry: entry, viewModel: viewModel)
                            } label: {
                                JournalEntryRow(entry: entry)
                            }
                        }
                        .onDelete(perform: deleteEntries)
                    }
                    .searchable(text: $searchText, prompt: "Search journal entries")
                }
            }
            .navigationTitle("Journal Entries")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showCreateEntry = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showCreateEntry) {
                CreateJournalEntryView(viewModel: viewModel)
            }
            .onAppear {
                viewModel.fetchAllJournalEntries()
            }
            .refreshable {
                viewModel.fetchAllJournalEntries()
            }
        }
    }
    
    private func deleteEntries(at offsets: IndexSet) {
        for index in offsets {
            let entry = filteredEntries[index]
            if let id = entry.id {
                Task {
                    _ = await viewModel.deleteJournalEntry(id: id)
                }
            }
        }
    }
}

struct JournalEntryRow: View {
    let entry: JournalEntry
    
    var totalDebits: Double {
        entry.lineItems.filter { $0.type == .debit }.reduce(0) { $0 + $1.amount }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: entry.isBalanced ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                .font(.title2)
                .foregroundColor(entry.isBalanced ? .green : .orange)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.entryNumber)
                    .font(.headline)
                
                Text(entry.description)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                HStack {
                    Text(entry.date, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .foregroundColor(.secondary)
                    
                    Text("\(entry.lineItems.count) line items")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(totalDebits, format: .currency(code: "USD"))
                    .font(.headline)
                    .foregroundColor(.primary)
                
                if !entry.isBalanced {
                    Text("Unbalanced")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

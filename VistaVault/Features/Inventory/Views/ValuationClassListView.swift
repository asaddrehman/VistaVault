import SwiftUI

struct ValuationClassListView: View {
    @StateObject private var viewModel = ValuationClassViewModel()
    @State private var showingAddSheet = false
    @State private var selectedClass: ValuationClass?
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Loading valuation classes...")
            } else if viewModel.valuationClasses.isEmpty {
                emptyStateView
            } else {
                classList
            }
        }
        .navigationTitle("Valuation Classes")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    selectedClass = nil
                    showingAddSheet = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            CreateValuationClassView(viewModel: viewModel)
        }
        .sheet(item: $selectedClass) { valuationClass in
            NavigationStack {
                ValuationClassDetailView(valuationClass: valuationClass, viewModel: viewModel)
            }
        }
    }
    
    private var classList: some View {
        List {
            ForEach(viewModel.valuationClasses) { valuationClass in
                Button {
                    selectedClass = valuationClass
                } label: {
                    ValuationClassRow(valuationClass: valuationClass)
                }
                .buttonStyle(.plain)
            }
        }
        .listStyle(.insetGrouped)
        .refreshable {
            viewModel.refreshData()
        }
    }
    
    private var emptyStateView: some View {
        ContentUnavailableView(
            "No Valuation Classes",
            systemImage: "tag.fill",
            description: Text("Add valuation classes to categorize inventory items")
        )
        .overlay(alignment: .bottom) {
            Button("Add Valuation Class") {
                showingAddSheet = true
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }
    }
}

struct ValuationClassRow: View {
    let valuationClass: ValuationClass
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "tag.fill")
                .font(.title2)
                .foregroundColor(AppConstants.Colors.brandPrimary)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(valuationClass.name)
                    .font(.headline)
                
                Text(valuationClass.classCode)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let description = valuationClass.description {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            if !valuationClass.isActive {
                Text("Inactive")
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(4)
            }
        }
        .padding(.vertical, 4)
    }
}

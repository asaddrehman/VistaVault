import SwiftUI

struct BusinessPartnerListView: View {
    @StateObject private var viewModel = BusinessPartnerViewModel()
    @State private var showingAddSheet = false
    @State private var selectedPartner: BusinessPartner?

    var body: some View {
        VStack(spacing: 0) {
            // Filter Picker
            Picker("Type", selection: $viewModel.selectedType) {
                Text("All").tag(nil as BusinessPartner.PartnerType?)
                ForEach(BusinessPartner.PartnerType.allCases, id: \.self) { type in
                    Text(type.rawValue).tag(type as BusinessPartner.PartnerType?)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            .onChange(of: viewModel.selectedType) { _, _ in
                viewModel.applyFilters()
            }

            // List
            if viewModel.isLoading {
                ProgressView("Loading partners...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.filteredPartners.isEmpty {
                ContentUnavailableView(
                    "No Business Partners",
                    systemImage: "person.2",
                    description: Text("Add customers and vendors to get started")
                )
            } else {
                List(viewModel.filteredPartners) { partner in
                    Button {
                        selectedPartner = partner
                    } label: {
                        BusinessPartnerRow(partner: partner)
                    }
                    .buttonStyle(.plain)
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Business Partners")
        .searchable(text: $viewModel.searchText, prompt: "Search partners...")
        .onChange(of: viewModel.searchText) { _, _ in
            viewModel.applyFilters()
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAddSheet = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            CreateBusinessPartnerView(viewModel: viewModel)
        }
        .sheet(item: $selectedPartner) { partner in
            NavigationStack {
                BusinessPartnerDetailView(partner: partner, viewModel: viewModel)
            }
        }
        .onAppear {
            if let userId = LocalAuthManager.shared.currentUserId {
                viewModel.fetchPartners(userId: userId)
            }
        }
    }
}

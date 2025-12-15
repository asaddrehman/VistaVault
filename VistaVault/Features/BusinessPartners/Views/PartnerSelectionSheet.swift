import SwiftUI

struct PartnerSelectionSheet: View {
    let partners: [BusinessPartner]
    @Binding var selectedPartner: BusinessPartner?
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""

    var filteredPartners: [BusinessPartner] {
        if searchText.isEmpty {
            return partners
        }
        return partners.filter { partner in
            partner.displayName.localizedCaseInsensitiveContains(searchText) ||
                partner.email?.localizedCaseInsensitiveContains(searchText) == true
        }
    }

    var body: some View {
        NavigationStack {
            List(filteredPartners) { partner in
                Button {
                    selectedPartner = partner
                    dismiss()
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(partner.displayName)
                                .font(.headline)

                            if let email = partner.email {
                                Text(email)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }

                        Spacer()

                        Text(partner.balance.sarFormatted())
                            .font(.subheadline)
                            .foregroundColor(partner.balance >= 0 ? .green : .red)
                    }
                }
            }
            .navigationTitle("Select Partner")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Search partners...")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authManager: LocalAuthManager
    @EnvironmentObject var profileVM: ProfileViewModel
    @State private var showingProfileEdit = false
    private let brandColor = Color.indigo

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Company Details Card
                    SectionCard(title: "Company Details", systemImage: "building.2.fill") {
                        VStack(spacing: 16) {
                            InfoRow(
                                label: "Organization Name",
                                value: profileVM.companyProfile.displayName
                            )
                            InfoRow(
                                label: "Mobile Number",
                                value: profileVM.companyProfile.mobile.ifEmpty(placeholder: "Not provided")
                            )
                            InfoRow(
                                label: "CR Number",
                                value: profileVM.companyProfile.crNumber.ifEmpty(placeholder: "Not registered")
                            )
                            InfoRow(
                                label: "Address",
                                value: profileVM.companyProfile.displayAddress
                            )

                            Divider().padding(.vertical)

                            InfoRow(
                                label: "Currency",
                                value: "\(profileVM.companyProfile.currencyCode) (\(profileVM.companyProfile.currencySymbol))"
                            )
                            InfoRow(
                                label: "Number Format",
                                value: profileVM.companyProfile.numberFormat.localeDisplayName
                            )
                        }
                        .padding(.vertical, 8)
                    }
                    .padding(.horizontal)

                    // Action Buttons
                    VStack(spacing: 16) {
                        Button {
                            showingProfileEdit = true
                        } label: {
                            ActionButton(
                                label: profileVM.isProfileComplete ? "Edit Profile" : "Complete Setup",
                                icon: profileVM.isProfileComplete ? "pencil.circle.fill" : "checkmark.circle.fill",
                                color: brandColor
                            )
                        }

                        Button {
                            authManager.signOut()
                        } label: {
                            ActionButton(
                                label: "Logout",
                                icon: "arrow.left.circle.fill",
                                color: .red
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Company Profile")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingProfileEdit) {
                CompanyProfileEditView(vm: profileVM)
                    .environmentObject(authManager)
                    .environmentObject(profileVM)
            }
            .onAppear {
                if let uid = authManager.currentUserId {
                    profileVM.loadProfile(uid: uid) // Direct method call
                }
            }
        }
    }
}

// Helper Views
struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(width: 120, alignment: .leading)

            Text(value)
                .font(.body)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
        }
    }
}

// Helper Extensions
extension String {
    func ifEmpty(placeholder: String) -> String {
        isEmpty ? placeholder : self
    }

    var localeDisplayName: String {
        Locale.current.localizedString(forIdentifier: self) ?? self
    }
}

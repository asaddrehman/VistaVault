import SwiftUI

/// Generic form template for creating/editing entities
/// Maximizes code reuse across all form views in the app
struct GenericFormTemplate<Content: View>: View {
    let title: String
    let isLoading: Bool
    let saveAction: () -> Void
    let cancelAction: () -> Void
    let content: () -> Content
    
    var isSaveDisabled: Bool = false
    var showDeleteButton: Bool = false
    var deleteAction: (() -> Void)?
    
    init(
        title: String,
        isLoading: Bool = false,
        isSaveDisabled: Bool = false,
        showDeleteButton: Bool = false,
        saveAction: @escaping () -> Void,
        cancelAction: @escaping () -> Void,
        deleteAction: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.isLoading = isLoading
        self.isSaveDisabled = isSaveDisabled
        self.showDeleteButton = showDeleteButton
        self.saveAction = saveAction
        self.cancelAction = cancelAction
        self.deleteAction = deleteAction
        self.content = content
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: AppConstants.Spacing.large) {
                    content()
                }
                .padding()
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        cancelAction()
                    }
                    .disabled(isLoading)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if isLoading {
                        ProgressView()
                    } else {
                        Button("Save") {
                            saveAction()
                        }
                        .fontWeight(.semibold)
                        .disabled(isSaveDisabled)
                    }
                }
                
                if showDeleteButton, let deleteAction = deleteAction {
                    ToolbarItem(placement: .bottomBar) {
                        Button(role: .destructive) {
                            deleteAction()
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        .disabled(isLoading)
                    }
                }
            }
        }
    }
}

/// Generic form section with consistent styling
struct FormSection<Content: View>: View {
    let title: String
    let icon: String?
    let content: () -> Content
    
    init(
        title: String,
        icon: String? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.icon = icon
        self.content = content
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.Spacing.medium) {
            HStack {
                if let icon = icon {
                    Image(systemName: icon)
                        .foregroundColor(AppConstants.Colors.brandPrimary)
                }
                Text(title)
                    .font(.headline)
            }
            .padding(.horizontal)
            
            VStack(spacing: AppConstants.Spacing.medium) {
                content()
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(AppConstants.CornerRadius.medium)
        }
    }
}

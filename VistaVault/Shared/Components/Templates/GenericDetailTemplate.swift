import SwiftUI

/// Generic detail view template for displaying entity details
/// Provides consistent layout and actions across all detail views
struct GenericDetailTemplate<Content: View>: View {
    let title: String
    let subtitle: String?
    let headerIcon: String?
    let isLoading: Bool
    let content: () -> Content
    
    var editAction: (() -> Void)?
    var deleteAction: (() -> Void)?
    var showEditButton: Bool = true
    var showDeleteButton: Bool = false
    
    init(
        title: String,
        subtitle: String? = nil,
        headerIcon: String? = nil,
        isLoading: Bool = false,
        showEditButton: Bool = true,
        showDeleteButton: Bool = false,
        editAction: (() -> Void)? = nil,
        deleteAction: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.headerIcon = headerIcon
        self.isLoading = isLoading
        self.showEditButton = showEditButton
        self.showDeleteButton = showDeleteButton
        self.editAction = editAction
        self.deleteAction = deleteAction
        self.content = content
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: AppConstants.Spacing.large) {
                // Header
                if let icon = headerIcon {
                    VStack(spacing: AppConstants.Spacing.medium) {
                        Image(systemName: icon)
                            .font(.system(size: 50))
                            .foregroundColor(AppConstants.Colors.brandPrimary)
                        
                        Text(title)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        if let subtitle = subtitle {
                            Text(subtitle)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                }
                
                // Content
                if isLoading {
                    ProgressView("Loading...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    content()
                }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if showEditButton, let editAction = editAction {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        editAction()
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    .disabled(isLoading)
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

/// Reusable detail row for key-value pairs
struct DetailRow: View {
    let label: String
    let value: String
    let icon: String?
    
    init(label: String, value: String, icon: String? = nil) {
        self.label = label
        self.value = value
        self.icon = icon
    }
    
    var body: some View {
        HStack {
            if let icon = icon {
                Image(systemName: icon)
                    .foregroundColor(AppConstants.Colors.brandPrimary)
                    .frame(width: 24)
            }
            
            Text(label)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .fontWeight(.medium)
        }
        .padding(.vertical, 8)
    }
}

/// Reusable detail section with consistent styling
struct DetailSection<Content: View>: View {
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
            
            VStack(alignment: .leading, spacing: AppConstants.Spacing.small) {
                content()
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(AppConstants.CornerRadius.medium)
        }
    }
}

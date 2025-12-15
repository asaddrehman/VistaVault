import SwiftUI

/// Base form template for consistent form layouts
struct BaseFormTemplate<Content: View>: View {
    let title: String
    let isLoading: Bool
    let canSave: Bool
    let onSave: () -> Void
    let onCancel: (() -> Void)?
    let content: Content

    init(
        title: String,
        isLoading: Bool = false,
        canSave: Bool = true,
        onSave: @escaping () -> Void,
        onCancel: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.isLoading = isLoading
        self.canSave = canSave
        self.onSave = onSave
        self.onCancel = onCancel
        self.content = content()
    }

    var body: some View {
        NavigationStack {
            Form {
                content
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    if let onCancel {
                        Button("Cancel") {
                            onCancel()
                        }
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(action: onSave) {
                        if isLoading {
                            ProgressView()
                        } else {
                            Text("Save")
                        }
                    }
                    .disabled(!canSave || isLoading)
                }
            }
        }
    }
}

/// Form field wrapper for consistent styling
struct FormFieldSection<Content: View>: View {
    let title: String
    let icon: String?
    let content: Content

    init(
        title: String,
        icon: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.icon = icon
        self.content = content()
    }

    var body: some View {
        Section {
            content
        } header: {
            if let icon {
                Label(title, systemImage: icon)
            } else {
                Text(title)
            }
        }
    }
}

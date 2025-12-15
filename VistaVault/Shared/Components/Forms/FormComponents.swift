import SwiftUI

// MARK: - Form TextField

struct FormTextField: View {
    let label: String
    let icon: String?
    @Binding var text: String
    var placeholder: String = ""
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.Spacing.small) {
            Label(label, systemImage: icon ?? "textformat")
                .font(.caption)
                .foregroundColor(.secondary)

            TextField(placeholder.isEmpty ? label : placeholder, text: $text)
                .keyboardType(keyboardType)
                .padding(AppConstants.Spacing.medium)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(AppConstants.CornerRadius.small)
        }
    }
}

// MARK: - Form Button

struct FormButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    var style: ButtonStyleType = .primary
    var isLoading: Bool = false
    var isDisabled: Bool = false

    enum ButtonStyleType {
        case primary, secondary, destructive

        var backgroundColor: Color {
            switch self {
            case .primary: AppConstants.Colors.brandPrimary
            case .secondary: .gray
            case .destructive: .red
            }
        }
    }

    var body: some View {
        Button(action: action) {
            HStack {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    if let icon {
                        Image(systemName: icon)
                    }
                    Text(title)
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(style.backgroundColor)
            .foregroundColor(.white)
            .cornerRadius(AppConstants.CornerRadius.medium)
        }
        .disabled(isDisabled || isLoading)
        .opacity(isDisabled ? 0.6 : 1.0)
    }
}

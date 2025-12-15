import SwiftUI

// MARK: - Custom Components

struct SectionCard<Content: View>: View {
    let title: String
    let systemImage: String
    let content: Content

    init(title: String, systemImage: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.systemImage = systemImage
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Label(title, systemImage: systemImage)
                    .font(.headline)
                    .foregroundColor(AppConstants.Colors.brandPrimary)
                Spacer()
            }
            content
        }
        .padding(AppConstants.Spacing.medium)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(AppConstants.CornerRadius.medium)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct IconTextField: View {
    let icon: String
    let label: String
    let text: Binding<String>
    var validationState: Bool?

    init(icon: String, label: String, text: Binding<String>, validation: Bool? = nil) {
        self.icon = icon
        self.label = label
        self.text = text
        validationState = validation
    }

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.gray)
                .frame(width: AppConstants.IconSize.small)

            TextField(label, text: text)
                .foregroundColor(.primary)
                .textInputAutocapitalization(.words)
                .disableAutocorrection(true)

            if let isValid = validationState {
                Image(systemName: isValid ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(isValid ? .green : .red)
            }
        }
        .padding(AppConstants.Spacing.medium)
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(AppConstants.CornerRadius.small)
    }

    func validation(_ isValid: Bool) -> some View {
        IconTextField(icon: icon, label: label, text: text, validation: isValid)
    }
}

struct GradientButton: View {
    let action: () -> Void
    let label: String
    var isLoading: Bool
    var isSuccess: Bool

    var body: some View {
        Button(action: action) {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else if isSuccess {
                    Image(systemName: "checkmark")
                } else {
                    Text(label)
                }
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(10)
            .scaleEffect(isSuccess ? 1.05 : 1)
            .animation(.spring(), value: isSuccess)
        }
    }
}

// -
struct DisclosureSection<Content: View>: View {
    @Binding var isExpanded: Bool
    let title: String
    let icon: String
    let content: () -> Content

    init(
        isExpanded: Binding<Bool>,
        title: String,
        icon: String,
        @ViewBuilder content: @escaping () -> Content
    ) {
        _isExpanded = isExpanded
        self.title = title
        self.icon = icon
        self.content = content
    }

    var body: some View {
        Section {
            if isExpanded {
                content()
            }
        } header: {
            DisclosureLabel(text: title, isExpanded: $isExpanded)
                .font(.headline)
                .padding(.bottom, isExpanded ? 8 : 0)
        }
        .animation(.easeInOut, value: isExpanded)
    }
}

struct DisclosureLabel: View {
    let text: String
    @Binding var isExpanded: Bool
    let icon: String?

    init(text: String, isExpanded: Binding<Bool>, icon: String? = nil) {
        self.text = text
        _isExpanded = isExpanded
        self.icon = icon
    }

    var body: some View {
        HStack {
            if let icon {
                Image(systemName: icon)
            }
            Text(text)
            Spacer()
            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
        }
        .contentShape(Rectangle())
        .onTapGesture { isExpanded.toggle() }
    }
}

// -
struct ValidationModifier: ViewModifier {
    let isValid: Bool

    func body(content: Content) -> some View {
        HStack {
            content
            Image(systemName: isValid ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(isValid ? .green : .red)
        }
    }
}

extension View {
    func validation(_ isValid: Bool) -> some View {
        modifier(ValidationModifier(isValid: isValid))
    }
}

import SwiftUI

// MARK: - Generic Form Field Protocol
protocol FormField {
    var label: String { get }
    var isRequired: Bool { get }
}

// MARK: - Form Date Picker
struct FormDatePicker: View {
    let label: String
    let icon: String?
    @Binding var date: Date
    var displayedComponents: DatePickerComponents = [.date]
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.Spacing.small) {
            Label(label, systemImage: icon ?? "calendar")
                .font(.caption)
                .foregroundColor(.secondary)
            
            DatePicker("", selection: $date, displayedComponents: displayedComponents)
                .labelsHidden()
                .padding(AppConstants.Spacing.medium)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(AppConstants.CornerRadius.small)
        }
    }
}

// MARK: - Form Picker
struct FormPicker<T: Hashable & CustomStringConvertible>: View {
    let label: String
    let icon: String?
    @Binding var selection: T
    let options: [T]
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.Spacing.small) {
            Label(label, systemImage: icon ?? "list.bullet")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Picker(label, selection: $selection) {
                ForEach(options, id: \.self) { option in
                    Text(option.description).tag(option)
                }
            }
            .pickerStyle(.menu)
            .padding(AppConstants.Spacing.medium)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(AppConstants.CornerRadius.small)
        }
    }
}

// MARK: - Form Currency Field
struct FormCurrencyField: View {
    let label: String
    let icon: String?
    @Binding var amount: Double
    var currencySymbol: String = "SAR"
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.Spacing.small) {
            Label(label, systemImage: icon ?? "dollarsign.circle")
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack {
                Text(currencySymbol)
                    .foregroundColor(.secondary)
                TextField("0.00", value: $amount, format: .number.precision(.fractionLength(2)))
                    .keyboardType(.decimalPad)
            }
            .padding(AppConstants.Spacing.medium)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(AppConstants.CornerRadius.small)
        }
    }
}

// MARK: - Form Toggle
struct FormToggle: View {
    let label: String
    let icon: String?
    @Binding var isOn: Bool
    var description: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.Spacing.small) {
            Toggle(isOn: $isOn) {
                HStack {
                    if let icon = icon {
                        Image(systemName: icon)
                            .foregroundColor(AppConstants.Colors.brandPrimary)
                    }
                    VStack(alignment: .leading) {
                        Text(label)
                            .font(.subheadline)
                        if let description = description {
                            Text(description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .padding(AppConstants.Spacing.medium)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(AppConstants.CornerRadius.small)
        }
    }
}

// MARK: - Form Text Editor
struct FormTextEditor: View {
    let label: String
    let icon: String?
    @Binding var text: String
    var placeholder: String = ""
    var height: CGFloat = 100
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.Spacing.small) {
            Label(label, systemImage: icon ?? "text.alignleft")
                .font(.caption)
                .foregroundColor(.secondary)
            
            ZStack(alignment: .topLeading) {
                if text.isEmpty {
                    Text(placeholder)
                        .foregroundColor(.gray.opacity(0.5))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 12)
                }
                TextEditor(text: $text)
                    .frame(height: height)
                    .padding(4)
            }
            .background(Color(.secondarySystemBackground))
            .cornerRadius(AppConstants.CornerRadius.small)
        }
    }
}

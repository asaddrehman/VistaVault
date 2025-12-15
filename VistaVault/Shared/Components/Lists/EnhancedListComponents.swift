import SwiftUI

// MARK: - Generic List Row
/// Generic row component that can be used for any entity type
struct GenericListRow<T>: View {
    let item: T
    let title: String
    let subtitle: String?
    let trailing: String?
    let icon: String
    let iconColor: Color
    
    init(
        item: T,
        title: String,
        subtitle: String? = nil,
        trailing: String? = nil,
        icon: String = "doc.text",
        iconColor: Color = .blue
    ) {
        self.item = item
        self.title = title
        self.subtitle = subtitle
        self.trailing = trailing
        self.icon = icon
        self.iconColor = iconColor
    }
    
    var body: some View {
        HStack(spacing: AppConstants.Spacing.medium) {
            // Icon
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.2))
                    .frame(width: AppConstants.IconSize.large, height: AppConstants.IconSize.large)
                
                Image(systemName: icon)
                    .foregroundColor(iconColor)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Trailing
            if let trailing = trailing {
                Text(trailing)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Status Badge
struct StatusBadge: View {
    let status: String
    var color: Color = .blue
    
    var body: some View {
        Text(status)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.2))
            .foregroundColor(color)
            .cornerRadius(8)
    }
}

// MARK: - Amount Display
struct AmountDisplay: View {
    let amount: Double
    let currencySymbol: String
    var isPositive: Bool? = nil
    
    var displayColor: Color {
        if let isPositive = isPositive {
            return isPositive ? .green : .red
        }
        return amount >= 0 ? .green : .red
    }
    
    var body: some View {
        Text("\(currencySymbol) \(amount, specifier: "%.2f")")
            .font(.subheadline)
            .fontWeight(.bold)
            .foregroundColor(displayColor)
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    let title: String
    let message: String
    let icon: String
    var actionTitle: String?
    var action: (() -> Void)?
    
    var body: some View {
        VStack(spacing: AppConstants.Spacing.large) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            VStack(spacing: AppConstants.Spacing.small) {
                Text(title)
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .fontWeight(.medium)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(AppConstants.Colors.brandPrimary)
                        .foregroundColor(.white)
                        .cornerRadius(AppConstants.CornerRadius.medium)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Loading State View
struct LoadingStateView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: AppConstants.Spacing.medium) {
            ProgressView()
                .scaleEffect(1.5)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Error State View
struct ErrorStateView: View {
    let error: Error
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: AppConstants.Spacing.large) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundColor(.red)
            
            VStack(spacing: AppConstants.Spacing.small) {
                Text("Something went wrong")
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Text(error.localizedDescription)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: retryAction) {
                Text("Try Again")
                    .fontWeight(.medium)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(AppConstants.Colors.brandPrimary)
                    .foregroundColor(.white)
                    .cornerRadius(AppConstants.CornerRadius.medium)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

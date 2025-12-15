import SwiftUI

// MARK: - Business Partner Row

struct BusinessPartnerRow: View {
    let partner: BusinessPartner

    var body: some View {
        HStack(spacing: AppConstants.Spacing.medium) {
            // Icon
            ZStack {
                Circle()
                    .fill(AppConstants.Colors.brandPrimary.opacity(0.2))
                    .frame(width: AppConstants.IconSize.large, height: AppConstants.IconSize.large)

                Image(systemName: partner.type.icon)
                    .foregroundColor(AppConstants.Colors.brandPrimary)
            }

            // Details
            VStack(alignment: .leading, spacing: 4) {
                Text(partner.displayName)
                    .font(.headline)

                HStack {
                    Text(partner.type.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    if let email = partner.email {
                        Text("•")
                            .foregroundColor(.secondary)
                        Text(email)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
            }

            Spacer()

            // Balance
            VStack(alignment: .trailing) {
                Text(partner.balance.sarFormatted())
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(partner.balance >= 0 ? .green : .red)

                if !partner.isActive {
                    Text("Inactive")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(AppConstants.Spacing.small)
    }
}

// MARK: - Account Row

struct AccountRow: View {
    let account: ChartOfAccount

    var body: some View {
        HStack(spacing: AppConstants.Spacing.medium) {
            // Icon
            Image(systemName: account.accountType.icon)
                .foregroundColor(AppConstants.Colors.brandPrimary)
                .frame(width: AppConstants.IconSize.medium)

            // Details
            VStack(alignment: .leading, spacing: 4) {
                Text(account.accountName)
                    .font(.headline)

                HStack {
                    Text(account.accountCode)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("•")
                        .foregroundColor(.secondary)
                    Text(account.accountType.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            // Balance
            Text(account.balance.sarFormatted())
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(account.balance >= 0 ? .primary : .red)
        }
        .padding(AppConstants.Spacing.small)
    }
}

// MARK: - Inventory Item Row

struct InventoryItemRow: View {
    let item: InventoryItem

    var body: some View {
        HStack(spacing: AppConstants.Spacing.medium) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: AppConstants.CornerRadius.small)
                    .fill(AppConstants.Colors.brandPrimary.opacity(0.2))
                    .frame(width: AppConstants.IconSize.large, height: AppConstants.IconSize.large)

                Image(systemName: "cube.box.fill")
                    .foregroundColor(AppConstants.Colors.brandPrimary)
            }

            // Details
            VStack(alignment: .leading, spacing: 4) {
                Text(item.displayName)
                    .font(.headline)

                HStack {
                    Text(item.productCode)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("•")
                        .foregroundColor(.secondary)
                    Text("Qty: \(item.availableQuantity)")
                        .font(.caption)
                        .foregroundColor(item.availableQuantity > 0 ? .green : .red)
                }
            }

            Spacer()

            // Price
            VStack(alignment: .trailing) {
                Text(item.salesPrice.sarFormatted())
                    .font(.subheadline)
                    .fontWeight(.bold)

                Text("Cost: \(item.purchasePrice.sarFormatted())")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(AppConstants.Spacing.small)
    }
}

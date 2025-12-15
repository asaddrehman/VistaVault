import SwiftUI

// Note: Requires Payment model and Double.sarFormatted() extension from CurrencyFormatter

struct TransactionRow: View {
    let payment: Payment
    let customerName: String

    var body: some View {
        HStack(spacing: AppConstants.Spacing.medium) {
            // Transaction Type Indicator
            transactionTypeIcon

            // Transaction Details
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .firstTextBaseline) {
                    Text(customerName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .lineLimit(1)

                    Spacer()

                    amountDisplay
                }

                // Transaction Metadata
                HStack(spacing: AppConstants.Spacing.medium) {
                    transactionBadge

                    Text(payment.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption2)
                        .foregroundColor(.secondary)

                    if let notes = payment.notes, !notes.isEmpty {
                        Text(notes)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }

                // Transaction Number
                Text("#\(payment.transactionNumber)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(AppConstants.Spacing.medium)
        .background(
            RoundedRectangle(cornerRadius: AppConstants.CornerRadius.large)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
        )
        .padding(.horizontal, 4)
    }

    // MARK: - Subviews

    private var transactionTypeIcon: some View {
        ZStack {
            RoundedRectangle(cornerRadius: AppConstants.CornerRadius.medium)
                .fill(transactionTypeGradient)
                .frame(width: AppConstants.IconSize.large, height: AppConstants.IconSize.large)

            Image(
                systemName: payment.transactionType == .credit
                    ? "arrow.down.circle.fill"
                    : "arrow.up.circle.fill"
            )
            .font(.system(size: 18, weight: .bold))
            .foregroundColor(.white)
        }
    }

    private var transactionBadge: some View {
        Text(payment.transactionType.rawValue.uppercased())
            .font(.system(size: 10, weight: .bold))
            .foregroundColor(transactionTypeColor)
            .padding(.horizontal, AppConstants.Spacing.small)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(transactionTypeColor.opacity(0.15))
            )
    }

    private var amountDisplay: some View {
        Text(payment.amount.sarFormatted())
            .font(.system(.subheadline, design: .rounded))
            .fontWeight(.bold)
            .foregroundStyle(transactionTypeGradient)
    }

    // MARK: - Computed Properties

    private var transactionTypeGradient: LinearGradient {
        payment.transactionType == .credit
            ? AppConstants.Colors.creditGradient
            : AppConstants.Colors.debitGradient
    }

    private var transactionTypeColor: Color {
        payment.transactionType == .credit
            ? AppConstants.Colors.creditColor
            : AppConstants.Colors.debitColor
    }
}

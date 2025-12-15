import SwiftUI

// Reusable Components
struct MetricView: View {
    let title: String
    let value: String
    let icon: String
    let gradient: LinearGradient
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.Spacing.medium) {
            HStack(spacing: AppConstants.Spacing.small) {
                ZStack {
                    RoundedRectangle(cornerRadius: AppConstants.CornerRadius.small)
                        .fill(color.opacity(0.2))
                        .frame(width: AppConstants.IconSize.large, height: AppConstants.IconSize.large)
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundStyle(gradient)
                }
            }
            Text(value)
                .font(.title3.bold())
                .foregroundStyle(gradient)

            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(AppConstants.Spacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: AppConstants.CornerRadius.large)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
        )
    }
}

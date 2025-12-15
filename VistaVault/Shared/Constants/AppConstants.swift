import SwiftUI

enum AppConstants {
    // MARK: - Colors

    enum Colors {
        static let brandPrimary = Color.indigo
        static let brandSecondary = Color("brandSecondary")
        static let creditColor = Color.green
        static let debitColor = Color.red

        static let creditGradient = LinearGradient(
            colors: [.green, .mint],
            startPoint: .top,
            endPoint: .bottom
        )

        static let debitGradient = LinearGradient(
            colors: [.red, .orange],
            startPoint: .top,
            endPoint: .bottom
        )

        static let brandGradient = LinearGradient(
            gradient: Gradient(colors: [brandPrimary, Color.purple]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // MARK: - Spacing

    enum Spacing {
        static let small: CGFloat = 8
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
        static let extraLarge: CGFloat = 32
    }

    // MARK: - Corner Radius

    enum CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let extraLarge: CGFloat = 20
    }

    // MARK: - Icon Sizes

    enum IconSize {
        static let small: CGFloat = 20
        static let medium: CGFloat = 28
        static let large: CGFloat = 40
        static let extraLarge: CGFloat = 64
    }

    // MARK: - Accounting Constants

    enum Accounting {
        static let floatingPointTolerance: Double = 0.01
    }

    // MARK: - Account Names

    enum AccountNames {
        static let cash = "Cash"
        static let accountsReceivable = "Accounts Receivable"
        static let accountsPayable = "Accounts Payable"
        static let inventory = "Inventory"
        static let revenue = "Revenue"
        static let salesRevenue = "Sales Revenue"
        static let serviceRevenue = "Service Revenue"
        static let costOfGoodsSold = "Cost of Goods Sold"
        static let ownersCapital = "Owner's Capital"
        static let retainedEarnings = "Retained Earnings"
    }
}

import SwiftUI

/// Centralized navigation coordinator for consistent navigation flow
class NavigationCoordinator: ObservableObject {
    @Published var selectedTab: AppTab = .dashboard
    @Published var navigationPath = NavigationPath()

    enum AppTab: Int, CaseIterable {
        case dashboard = 0
        case menu = 1
        case payments = 2
        case profile = 3

        var title: String {
            switch self {
            case .dashboard: "Dashboard"
            case .menu: "Menu"
            case .payments: "Payments"
            case .profile: "Profile"
            }
        }

        var icon: String {
            switch self {
            case .dashboard: "house.fill"
            case .menu: "menucard.fill"
            case .payments: "dollarsign.circle.fill"
            case .profile: "person.crop.circle.fill"
            }
        }
    }

    // MARK: - Navigation Methods

    func navigate(to tab: AppTab) {
        selectedTab = tab
    }

    func push(_ value: some Hashable) {
        navigationPath.append(value)
    }

    func pop() {
        navigationPath.removeLast()
    }

    func popToRoot() {
        navigationPath = NavigationPath()
    }
}

/// Navigation destinations enum for type-safe navigation
enum NavigationDestination: Hashable {
    case customerDetail(BusinessPartner)
    case invoiceDetail(Invoice)
    case paymentDetail(Payment)
    case accountDetail(ChartOfAccount)
    case inventoryDetail(InventoryItem)
}

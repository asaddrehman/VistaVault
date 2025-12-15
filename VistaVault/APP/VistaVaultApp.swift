import SwiftUI
import GRDB

@main
struct VistaVaultApp: App {
    @StateObject var authManager = LocalAuthManager.shared
    let dataController = GRDBDataController.shared

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authManager)
                .environmentObject(DatabaseContainer(dbQueue: dataController.dbQueue))
        }
    }
}

// Environment object to pass database queue through the view hierarchy
class DatabaseContainer: ObservableObject {
    let dbQueue: DatabaseQueue
    
    init(dbQueue: DatabaseQueue) {
        self.dbQueue = dbQueue
    }
}

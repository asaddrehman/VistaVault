//
//  RootView.swift
//  VistaVault
//
//  Created by Asad ur Rehman on 05/11/1446 AH.
//
import SwiftUI

struct RootView: View {
    @EnvironmentObject var authManager: LocalAuthManager
    @StateObject var profileVM = ProfileViewModel()
    @StateObject var businessPartnerVM = BusinessPartnerViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if authManager.isLoggedIn {
                    HomeView()
                        .environmentObject(profileVM)
                        .environmentObject(businessPartnerVM)
                } else {
                    AuthView()
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: authManager.isLoggedIn)
        }
        .onAppear {
            loadProfileIfNeeded()
        }
        .onChange(of: authManager.isLoggedIn) { _, newValue in
            if newValue {
                loadProfileIfNeeded()
            }
        }
    }

    private func loadProfileIfNeeded() {
        guard authManager.isLoggedIn,
              let uid = authManager.currentUserId else { return }

        profileVM.loadProfile(uid: uid)

        // Load other essential data
        businessPartnerVM.fetchPartners(userId: uid)
    }
}

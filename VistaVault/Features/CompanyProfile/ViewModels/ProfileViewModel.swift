//
//  CompanyProfileViewModel.swift
//  ValueVault
//
//  Created by Asad ur Rehman on 03/11/1446 AH.
//  Copyright © 1446 AH CodeCraft. All rights reserved.
//
import Combine
import Foundation
import GRDB

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var companyProfile: CompanyProfile = .empty
    @Published var isProfileComplete: Bool = false
    private let dataController = GRDBDataController.shared

    init() { }

    // -
    private func updateCompletionStatus() {
        isProfileComplete = companyProfile.isSetupComplete
        UserDefaults.standard.set(isProfileComplete, forKey: "isSetupComplete")
    }

    // -
    func loadProfile(uid: String) {
        Task {
            do {
                let profileData = try await dataController.dbQueue.read { db in
                    try CompanyProfileData
                        .filter(Column("userId") == uid)
                        .fetchOne(db)
                }

                if let profileData = profileData {
                    companyProfile = CompanyProfile(from: profileData)
                    updateCompletionStatus()
                } else {
                    companyProfile = .empty
                }
            } catch {
                print("Profile load error: \(error.localizedDescription)")
                companyProfile = .empty
            }
        }
    }

    func saveProfile(uid: String) {
        guard validateProfile() else {
            print("Validation failed")
            return
        }

        companyProfile.isSetupComplete = true

        Task {
            do {
                // Fetch user to ensure it exists
                guard let _ = try dataController.fetchUser(byId: uid) else {
                    print("Profile save failed: User not found")
                    return
                }

                // Capture profile data before entering async closure
                let profileToSave = self.companyProfile
                
                try await dataController.dbQueue.write { db in
                    // Check if profile exists
                    if var existingProfile = try CompanyProfileData
                        .filter(Column("userId") == uid)
                        .fetchOne(db) {
                        // Update existing profile
                        existingProfile.name = profileToSave.name
                        existingProfile.mobile = profileToSave.mobile
                        existingProfile.crNumber = profileToSave.crNumber
                        existingProfile.address = profileToSave.address
                        existingProfile.currencyCode = profileToSave.currencyCode
                        existingProfile.currencySymbol = profileToSave.currencySymbol
                        existingProfile.numberFormat = profileToSave.numberFormat
                        existingProfile.isSetupComplete = profileToSave.isSetupComplete
                        try existingProfile.update(db)
                    } else {
                        // Create new profile
                        var profileData = profileToSave.toData()
                        profileData.userId = uid
                        try profileData.insert(db)
                    }
                }
                
                self.updateCompletionStatus()
            } catch {
                print("Profile save failed: \(error)")
            }
        }
    }

    // MARK: - Validation

    func validateProfile() -> Bool {
        !companyProfile.name.isEmpty &&
            !companyProfile.mobile.isEmpty &&
            !companyProfile.crNumber.isEmpty &&
            !companyProfile.address.isEmpty &&
            !companyProfile.currencyCode.isEmpty &&
            !companyProfile.currencySymbol.isEmpty &&
            !companyProfile.numberFormat.isEmpty
    }

    // MARK: - UI Helpers

    func formattedCurrency(_ amount: Double) -> String {
        guard !companyProfile.currencyCode.isEmpty else {
            return String(format: "%.2f", amount)
        }

        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = companyProfile.currencyCode
        formatter.currencySymbol = companyProfile.currencySymbol
        return formatter.string(from: NSNumber(value: amount)) ?? String(format: "%.2f", amount)
    }
}

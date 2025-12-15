//
//  EditCompanyProfileView.swift
//  ValueVault
//
//  Created by Asad ur Rehman on 02/11/1446 AH.
//  Copyright © 1446 AH CodeCraft. All rights reserved.
//
import SwiftUI

struct CompanyProfileEditView: View {
    @ObservedObject var vm: ProfileViewModel
    @Environment(\.dismiss) var dismiss
    @State private var selectedCurrency: String = ""
    @State private var selectedNumberFormat: String = ""

    // Available options (should match your business requirements)
    private let currencies = [
        ("SAR", "ر.س"),
        ("USD", "$"),
        ("EUR", "€")
    ]

    private let numberFormats = [
        ("en_US", "1,234.56"),
        ("ar_SA", "١٬٢٣٤٫٥٦")
    ]

    var body: some View {
        NavigationStack {
            Form {
                // Company Information Section
                Section(header: Text("Company Information")) {
                    TextField("Legal Name", text: $vm.companyProfile.name)
                    TextField("Address", text: $vm.companyProfile.address, axis: .vertical)
                }

                // Contact Details Section
                Section(header: Text("Contact Details")) {
                    TextField("Mobile Number", text: $vm.companyProfile.mobile)
                        .keyboardType(.phonePad)
                }

                // Business Details Section
                Section(header: Text("Business Details")) {
                    TextField("CR Number", text: $vm.companyProfile.crNumber)
                        .keyboardType(.numberPad)
                }

                // Regional Settings Section
                Section(header: Text("Regional Settings")) {
                    Picker("Currency", selection: $vm.companyProfile.currencyCode) {
                        ForEach(currencies, id: \.0) { code, symbol in
                            Text("\(code) (\(symbol))").tag(code)
                        }
                    }
                    .disabled(vm.companyProfile.isSetupComplete)

                    Picker("Number Format", selection: $vm.companyProfile.numberFormat) {
                        ForEach(numberFormats, id: \.0) { code, example in
                            Text("\(example) (\(code))").tag(code)
                        }
                    }
                    .disabled(vm.companyProfile.isSetupComplete)
                }

                // Legal Compliance Section
                Section {
                    Text("By completing this profile, you agree to our Terms of Service")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle(vm.companyProfile.isSetupComplete ? "Company Profile" : "Setup Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: saveProfile) {
                        Text(vm.companyProfile.isSetupComplete ? "Update" : "Save")
                    }
                    .disabled(!vm.validateProfile())
                }

                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                if !vm.companyProfile.isSetupComplete {
                    setDefaultRegionalSettings()
                }
            }
        }
    }

    private func saveProfile() {
        vm.saveProfile(uid: LocalAuthManager.shared.currentUserId ?? "")
        dismiss()
    }

    private func setDefaultRegionalSettings() {
        if vm.companyProfile.currencyCode.isEmpty {
            vm.companyProfile.currencyCode = "SAR"
            vm.companyProfile.currencySymbol = "ر.س"
            vm.companyProfile.numberFormat = "ar_SA"
        }
    }
}

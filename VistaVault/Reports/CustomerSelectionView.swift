//
//  CustomerSelectionView.swift
//  ValueVault
//
//  Created by Asad ur Rehman on 30/10/1446 AH.
//
import SwiftUI

struct CustomerSelectionView: View {
    let customers: [Customer]
    @Binding var selectedCustomer: Customer?

    var body: some View {
        NavigationStack {
            List(customers) { customer in
                Button {
                    selectedCustomer = customer
                } label: {
                    HStack {
                        Text(customer.displayName)
                        Spacer()
                        if selectedCustomer?.id == customer.id {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .navigationTitle("Select Customer")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        // Dismiss
                    }
                }
            }
        }
    }
}

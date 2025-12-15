//
//  CustomerSummaryView.swift
//  ValueVault
//
//  Created by Asad ur Rehman on 04/11/1446 AH.
//  Copyright © 1446 AH CodeCraft. All rights reserved.
//
import SwiftUI

struct CustomerSummaryView: View {
    let customer: Customer
    var onRemove: () -> Void

    var body: some View {
        HStack {
            HStack {
                // Customer Avatar
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [.blue, .blue.opacity(0.4)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 40, height: 40)

                    Text(customer.name.prefix(1).uppercased())
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }

                // Customer Details
                VStack(alignment: .leading, spacing: 4) {
                    Text(customer.displayName)
                        .font(.subheadline)
                        .fontWeight(.medium)

                    if let phone = customer.phone {
                        Text(phone)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10)

            // Remove Button
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
                    .font(.title2)
            }
        }
    }
}

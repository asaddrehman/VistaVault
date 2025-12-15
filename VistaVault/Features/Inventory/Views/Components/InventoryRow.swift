//
//  InventoryRow.swift
//  VistaVault
//
//  Created by Asad ur Rehman on 06/11/1446 AH.
//
import SwiftUI

struct InventoryRow: View {
    let item: InventoryItem
    let units: [Unit]
    private let brandPrimary = Color("brandPrimary")
    private let brandSecondary = Color("brandSecondary")
    private let borderColor = Color("inventoryBorder")

    private var unitName: String {
        units.first { $0.id == item.unitId }?.name ?? "No Unit"
    }

    private var quantityStatus: (text: String, color: Color, icon: String) {
        switch item.availableQuantity {
        case ...0: ("Out of Stock", .negativeRed, "xmark.circle.fill")
        case 1 ... 10: ("Low Stock", .warningOrange, "exclamationmark.triangle.fill")
        default: ("In Stock", .positiveGreen, "checkmark.circle.fill")
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.displayName)
                        .font(.headline)
                        .accessibilityHeading(.h3) // Semantic heading

                    Text(item.productCode)
                        .font(.caption)
                        .accessibilityLabel("Product code: \(item.productCode)")
                }

                Spacer()

                statusIndicator
                    .accessibilityElement(children: .combine) // Groups icon + text
            }

            HStack(spacing: 16) {
                quantityBadge
                priceInfo
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(borderColor, lineWidth: 1)
                )
        )
        .accessibilityElement(children: .combine) // Groups entire row content

    }

    private var statusIndicator: some View {
        HStack(spacing: 4) {
            Image(systemName: quantityStatus.icon)
                .symbolVariant(.fill) // Standard symbol style
            Text(quantityStatus.text) // Added text label for clarity
                .font(.caption2)
        }
        .foregroundColor(quantityStatus.color)
        .padding(8)
        .background(quantityStatus.color.opacity(0.1))
        .clipShape(Capsule())
        .accessibilityLabel("Stock status: \(quantityStatus.text)") // Combined label
    }

    private var quantityBadge: some View {
        HStack(spacing: 8) {
            Image(systemName: "cube.fill")
                .accessibilityHidden(true) // Decorative image

            VStack(alignment: .leading) {
                Text("Available Stock")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .accessibilityLabel("Available quantity")

                HStack(spacing: 4) {
                    Text("\(item.availableQuantity)")
                        .font(.subheadline.weight(.medium))
                        .accessibilityValue("\(item.availableQuantity) \(unitName)")

                    Text(unitName)
                        .font(.caption)
                        .accessibilityHidden(true) // Value already captured above
                }
            }
        }
        .padding(8)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(8)
    }

    private var priceInfo: some View {
        VStack(alignment: .trailing) {
            Text(item.salesPrice, format: .currency(code: "SAR"))
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.green.gradient)

            Text("Cost: \(item.purchasePrice, format: .currency(code: "SAR"))")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

extension Color {
    static let tertiarySystemBackground = Color(uiColor: .tertiarySystemBackground)
}

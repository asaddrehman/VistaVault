//
//  CurrencyFormatter.swift
//  VistaVault
//
//  Created by Asad ur Rehman on 06/11/1446 AH.
//
import SwiftUI

class CurrencyFormatter {
    static let shared = CurrencyFormatter()
    private var formatter = NumberFormatter()

    func configure(with profile: CompanyProfile) {
        formatter.numberStyle = .currency
        formatter.currencyCode = profile.currencyCode
        formatter.currencySymbol = profile.currencySymbol
        formatter.locale = Locale(identifier: profile.numberFormat)
    }

    func format(_ amount: Double) -> String {
        formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
    }
}

extension Double {
    func formattedCurrency(profile: CompanyProfile) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = profile.currencyCode
        formatter.currencySymbol = profile.currencySymbol
        formatter.locale = Locale(identifier: profile.numberFormat)

        guard let formatted = formatter.string(from: NSNumber(value: self)) else {
            return String(format: "%.2f", self)
        }
        return formatted
    }

    /// Format as SAR currency (Saudi Riyal)
    func sarFormatted() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "SAR"
        formatter.currencySymbol = "ر.س"
        return formatter.string(from: NSNumber(value: self)) ?? "\(self) ر.س"
    }
}

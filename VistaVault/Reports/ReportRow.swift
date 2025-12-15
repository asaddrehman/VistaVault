//
//  ReportRow.swift
//  VistaVault
//
//  Created by Asad ur Rehman on 30/10/1446 AH.
//  Note: This is now a type alias to the unified TransactionRow component
//
import SwiftUI

// Use unified TransactionRow component for consistency
typealias ReportRow = TransactionRow

extension PaymentTransactionType {
    var color: Color {
        switch self {
        case .credit: .green
        case .debit: .red
        }
    }

    var displayName: String {
        rawValue.capitalized
    }
}

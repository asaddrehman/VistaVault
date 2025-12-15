import SwiftUI

struct CompanyProfile: Codable, Identifiable {
    var id: String
    var name: String
    var mobile: String
    var crNumber: String
    var address: String
    var currencyCode: String
    var currencySymbol: String
    var numberFormat: String
    var isSetupComplete: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case mobile = "mobilenumber"
        case crNumber = "crnumber"
        case address
        case currencyCode = "currency_code"
        case currencySymbol = "currency_symbol"
        case numberFormat = "number_format"
        case isSetupComplete = "setup_complete"
    }

    static let empty = CompanyProfile(
        id: "",
        name: "",
        mobile: "",
        crNumber: "",
        address: "",
        currencyCode: "",
        currencySymbol: "",
        numberFormat: "",
        isSetupComplete: false
    )

    var displayName: String {
        name.isEmpty ? "Business Name Not Provided" : name
    }

    var displayAddress: String {
        address.isEmpty ? "Address Not Provided" : address
    }
}

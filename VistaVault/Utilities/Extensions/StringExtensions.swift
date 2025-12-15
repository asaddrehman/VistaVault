import Foundation

extension String {
    /// Convert empty string to nil, otherwise return the string
    var nonEmptyOrNil: String? {
        isEmpty ? nil : self
    }
}

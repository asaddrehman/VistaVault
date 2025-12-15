import Foundation

enum AppError: LocalizedError {
    // Authentication Errors
    case authenticationFailed
    case authenticationRequired
    case userNotFound
    case invalidCredentials
    case sessionExpired

    // Data Errors
    case dataNotFound
    case invalidData
    case notFound(message: String)
    case saveFailed
    case deleteFailed
    case updateFailed

    // Validation Errors
    case validationFailed(String)
    case requiredFieldMissing(String)
    case invalidInput(String)

    // Accounting Errors
    case journalEntryNotBalanced
    case invalidAccountType
    case insufficientBalance
    case invalidAmount

    // Network Errors
    case networkError
    case serverError
    case timeout

    // Generic
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        // Authentication
        case .authenticationFailed:
            "Authentication failed. Please try again."
        case .authenticationRequired:
            "Authentication is required. Please log in."
        case .userNotFound:
            "User not found. Please check your credentials."
        case .invalidCredentials:
            "Invalid email or password."
        case .sessionExpired:
            "Your session has expired. Please log in again."
        // Data
        case .dataNotFound:
            "The requested data could not be found."
        case .invalidData:
            "Invalid data format."
        case .notFound(let message):
            message
        case .saveFailed:
            "Failed to save data. Please try again."
        case .deleteFailed:
            "Failed to delete item. Please try again."
        case .updateFailed:
            "Failed to update item. Please try again."
        // Validation
        case .validationFailed(let message):
            message
        case .requiredFieldMissing(let field):
            "\(field) is required."
        case .invalidInput(let message):
            message
        // Accounting
        case .journalEntryNotBalanced:
            "Journal entry is not balanced. Total debits must equal total credits."
        case .invalidAccountType:
            "Invalid account type selected."
        case .insufficientBalance:
            "Insufficient balance for this transaction."
        case .invalidAmount:
            "Please enter a valid amount."
        // Network
        case .networkError:
            "Network error. Please check your connection."
        case .serverError:
            "Server error. Please try again later."
        case .timeout:
            "Request timed out. Please try again."
        // Generic
        case .unknown(let error):
            "An error occurred: \(error.localizedDescription)"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .authenticationFailed, .invalidCredentials:
            "Please check your email and password and try again."
        case .networkError, .timeout:
            "Please check your internet connection and try again."
        case .journalEntryNotBalanced:
            "Ensure that the total debits equal total credits before saving."
        case .insufficientBalance:
            "Please check the account balance before proceeding."
        default:
            "If the problem persists, please contact support."
        }
    }
}

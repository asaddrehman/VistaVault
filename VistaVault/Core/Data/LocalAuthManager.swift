import CryptoKit
import Foundation
import SwiftUI

@MainActor
class LocalAuthManager: ObservableObject {
    static let shared = LocalAuthManager()

    @Published var isLoggedIn = false
    @Published var currentUser: User?

    private let dataController = DataController.shared
    private let userDefaultsKey = "currentUserId"

    private init() {
        // Check if there's a stored user session
        if let userId = UserDefaults.standard.string(forKey: userDefaultsKey) {
            Task {
                await loadUserSession(userId: userId)
            }
        }
    }

    var currentUserId: String? {
        currentUser?.id
    }

    // MARK: - Authentication Methods

    func signIn(email: String, password: String) async throws {
        // Fetch user from database
        guard let user = try dataController.fetchUser(byEmail: email) else {
            throw AuthError.userNotFound
        }

        // Verify password
        let passwordHash = hashPassword(password)
        guard user.passwordHash == passwordHash else {
            throw AuthError.invalidPassword
        }

        // Set current user
        currentUser = user
        isLoggedIn = true

        // Store session
        UserDefaults.standard.set(user.id, forKey: userDefaultsKey)
    }

    func createUser(email: String, password: String) async throws {
        // Check if user already exists
        if try dataController.fetchUser(byEmail: email) != nil {
            throw AuthError.emailAlreadyExists
        }

        // Create new user
        let passwordHash = hashPassword(password)
        let user = try dataController.createUser(email: email, passwordHash: passwordHash)

        // Set current user
        currentUser = user
        isLoggedIn = true

        // Store session
        UserDefaults.standard.set(user.id, forKey: userDefaultsKey)
    }

    func signOut() {
        currentUser = nil
        isLoggedIn = false
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
    }

    func sendPasswordReset(email: String) async throws {
        // In a real app, you'd implement password reset functionality
        // For now, we'll just verify the user exists
        guard try dataController.fetchUser(byEmail: email) != nil else {
            throw AuthError.userNotFound
        }

        // In production, you'd send a reset email or provide a mechanism to reset password
        // For now, just throw success
    }

    // MARK: - Private Methods

    private func loadUserSession(userId: String) async {
        do {
            if let user = try dataController.fetchUser(byId: userId) {
                currentUser = user
                isLoggedIn = true
            } else {
                // Invalid session, clear it
                UserDefaults.standard.removeObject(forKey: userDefaultsKey)
            }
        } catch {
            print("Error loading user session: \(error)")
            UserDefaults.standard.removeObject(forKey: userDefaultsKey)
        }
    }

    private func hashPassword(_ password: String) -> String {
        let inputData = Data(password.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
}

// MARK: - Auth Errors

enum AuthError: LocalizedError {
    case userNotFound
    case invalidPassword
    case emailAlreadyExists
    case invalidEmail
    case weakPassword

    var errorDescription: String? {
        switch self {
        case .userNotFound:
            "No user found with this email address."
        case .invalidPassword:
            "Incorrect password. Please try again."
        case .emailAlreadyExists:
            "An account with this email already exists."
        case .invalidEmail:
            "Please enter a valid email address."
        case .weakPassword:
            "Password does not meet security requirements."
        }
    }
}

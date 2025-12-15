import SwiftUI

/// AuthView provides user authentication functionality for the VistaVault application.
///
/// # Security & Encryption Implementation
///
/// This view implements secure user authentication using Firebase Authentication,
/// which provides enterprise-grade security with the following encryption standards:
///
/// ## Password Security
/// - **Hashing Algorithm**: Modified scrypt (memory-hard key derivation function)
/// - **Security Level**: High - resistant to brute-force attacks via custom hardware (ASICs, GPUs)
/// - **Storage**: Passwords are never stored in plain text; only cryptographically secure hashes
/// - **Parameters**: Project-specific scrypt parameters including salt separator, rounds, and memory cost
///
/// ## Transport Security
/// - **Protocol**: HTTPS with TLS (Transport Layer Security)
/// - **Encryption**: End-to-end encryption for all authentication requests
/// - **Handshake**: Asymmetric cryptography (RSA or ECC)
/// - **Data Transfer**: Symmetric encryption (AES-256)
///
/// ## Password Requirements
/// The app enforces strong password policies:
/// - Minimum 8 characters
/// - At least one lowercase letter
/// - At least one uppercase letter
/// - At least one number
/// - At least one special character (@$!%*?&)
///
/// ## Additional Security Features
/// - Email verification support
/// - Secure password reset via email
/// - Session management with secure tokens
/// - Protection against common authentication attacks
///
/// For more information on Firebase Authentication security:
/// - Scrypt algorithm: https://firebaseopensource.com/projects/firebase/scrypt
/// - Security best practices: https://firebase.google.com/docs/auth/
///
struct AuthView: View {
    @EnvironmentObject var authManager: LocalAuthManager
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isLoginMode = true
    @State private var errorMessage = ""
    @State private var isLoading = false
    @FocusState private var focusedField: Field?
    @State private var showPasswordReset = false
    @State private var resetEmail = ""
    @State private var showResetSent = false

    enum Field: Hashable {
        case email, password, confirmPassword
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Gradient Background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(.systemGroupedBackground),
                        AppConstants.Colors.brandSecondary.opacity(0.1)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                // Main Content
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 24) {
                            // Header
                            headerSection

                            // Input Form
                            VStack(spacing: 20) {
                                inputFields

                                errorMessageSection

                                submitButton

                                // Password Reset Button (Login mode only)
                                if isLoginMode {
                                    Button("Forgot Password?") {
                                        showPasswordReset = true
                                        resetEmail = email
                                    }
                                    .font(.subheadline)
                                    .foregroundColor(AppConstants.Colors.brandSecondary)
                                    .padding(.top, AppConstants.Spacing.small)
                                }
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(20)
                            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                            .padding(.horizontal)

                            authToggleSection
                        }
                        .padding(.vertical, 30)
                    }
                    .onChange(of: focusedField) { _, field in
                        guard let field else { return }
                        withAnimation(.easeOut(duration: 0.2)) {
                            proxy.scrollTo(field, anchor: .center)
                        }
                    }
                }
            }
            .navigationTitle(isLoginMode ? "Welcome Back" : "Get Started")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showPasswordReset) {
                passwordResetSheet
            }
            .alert("Reset Email Sent", isPresented: $showResetSent) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Please check your email for password reset instructions.")
            }
        }
    }

    // MARK: - Subviews

    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 64))
                .foregroundStyle(
                    LinearGradient(
                        colors: [AppConstants.Colors.brandSecondary, AppConstants.Colors.brandSecondary.opacity(0.7)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            VStack(spacing: 4) {
                Text("Value Vault")
                    .font(.system(size: 34, weight: .heavy, design: .rounded))

                Text("Secure Your Finances")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }

    private var inputFields: some View {
        Group {
            // Email Field
            VStack(alignment: .leading, spacing: 8) {
                Text("Email Address")
                    .font(.caption)
                    .foregroundColor(.secondary)
                TextField("name@example.com", text: $email)
                    .focused($focusedField, equals: .email)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .submitLabel(.next)
                    .padding(12)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                    .id(Field.email)
                    .onSubmit { focusedField = .password }
            }

            // Password Field
            VStack(alignment: .leading, spacing: 8) {
                Text("Password")
                    .font(.caption)
                    .foregroundColor(.secondary)
                SecureField("Enter password", text: $password)
                    .focused($focusedField, equals: .password)
                    .textContentType(isLoginMode ? .password : .newPassword)
                    .submitLabel(isLoginMode ? .go : .next)
                    .padding(12)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                    .id(Field.password)
                    .onSubmit {
                        if isLoginMode {
                            handleAuth()
                        } else {
                            focusedField = .confirmPassword
                        }
                    }

                // Password Requirements (Signup only)
                if !isLoginMode {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Password must contain:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        RequirementRow(isMet: password.count >= 8, text: "At least 8 characters")
                        RequirementRow(isMet: hasLowercase, text: "One lowercase letter")
                        RequirementRow(isMet: hasUppercase, text: "One uppercase letter")
                        RequirementRow(isMet: hasNumber, text: "One number")
                        RequirementRow(isMet: hasSpecialCharacter, text: "One special character (@$!%*?&)")
                    }
                    .padding(.top, 4)
                }
            }

            // Confirm Password Field (Signup only)
            if !isLoginMode {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Confirm Password")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    SecureField("Re-enter password", text: $confirmPassword)
                        .focused($focusedField, equals: .confirmPassword)
                        .textContentType(.newPassword)
                        .submitLabel(.go)
                        .padding(12)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(8)
                        .id(Field.confirmPassword)
                        .onSubmit { handleAuth() }
                }
            }
        }
    }

    private var errorMessageSection: some View {
        Group {
            if !errorMessage.isEmpty {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                    Text(errorMessage)
                }
                .font(.caption)
                .foregroundColor(.white)
                .padding(10)
                .frame(maxWidth: .infinity)
                .background(Color.red.opacity(0.9))
                .cornerRadius(8)
            }
        }
    }

    private var submitButton: some View {
        Button(action: handleAuth) {
            HStack {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: isLoginMode ? "arrow.right.square" : "person.badge.plus")
                }
                Text(isLoginMode ? "Sign In" : "Create Account")
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(AppConstants.Colors.brandSecondary.gradient)
            .cornerRadius(AppConstants.CornerRadius.medium)
            .shadow(color: AppConstants.Colors.brandSecondary.opacity(0.3), radius: 10, x: 0, y: 5)
        }
        .disabled(!formIsValid || isLoading)
        .opacity(formIsValid ? 1 : 0.6)
    }

    private var authToggleSection: some View {
        HStack {
            Text(isLoginMode ? "New to Value Vault?" : "Already have an account?")
                .foregroundColor(.secondary)

            Button(isLoginMode ? "Create Account" : "Sign In") {
                withAnimation(.spring()) {
                    isLoginMode.toggle()
                    errorMessage = ""
                    confirmPassword = ""
                }
            }
            .font(.subheadline.weight(.medium))
            .foregroundColor(AppConstants.Colors.brandSecondary)
        }
        .font(.subheadline)
    }

    // MARK: - Password Reset Components

    private var passwordResetSheet: some View {
        VStack(spacing: 20) {
            Text("Reset Password")
                .font(.title2.bold())

            TextField("Enter your email", text: $resetEmail)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)

            Button(action: sendPasswordReset) {
                HStack {
                    Image(systemName: "paperplane.fill")
                    Text("Send Reset Link")
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(AppConstants.Colors.brandSecondary)
                .cornerRadius(AppConstants.CornerRadius.small)
            }
            .disabled(!isValidResetEmail)
            .opacity(isValidResetEmail ? 1 : 0.6)

            Button("Cancel") {
                showPasswordReset = false
            }
            .foregroundColor(.secondary)
        }
        .padding()
        .presentationDetents([.height(280)])
    }

    // MARK: - Validation & Auth Logic

    private var formIsValid: Bool {
        // Email validation
        guard email.contains("@"), email.contains(".") else { return false }

        // Password validation
        let passwordRegex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@$!%*?&])[A-Za-z\\d@$!%*?&]{8,}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        guard predicate.evaluate(with: password) else { return false }

        // Confirm password
        if !isLoginMode {
            guard password == confirmPassword else { return false }
        }

        return true
    }

    private var isValidResetEmail: Bool {
        resetEmail.contains("@") && resetEmail.contains(".")
    }

    // Password requirement checks
    private var hasLowercase: Bool {
        password.rangeOfCharacter(from: .lowercaseLetters) != nil
    }

    private var hasUppercase: Bool {
        password.rangeOfCharacter(from: .uppercaseLetters) != nil
    }

    private var hasNumber: Bool {
        password.rangeOfCharacter(from: .decimalDigits) != nil
    }

    private var hasSpecialCharacter: Bool {
        let specialChars = CharacterSet(charactersIn: "@$!%*?&")
        return password.rangeOfCharacter(from: specialChars) != nil
    }

    private func handleAuth() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)

        withAnimation {
            isLoading = true
            errorMessage = ""
            focusedField = nil
        }

        Task {
            do {
                if isLoginMode {
                    try await loginUser()
                } else {
                    try await createUser()
                }
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            } catch {
                await MainActor.run {
                    UINotificationFeedbackGenerator().notificationOccurred(.error)
                    errorMessage = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }

    private func sendPasswordReset() {
        Task {
            isLoading = true
            do {
                try await authManager.sendPasswordReset(email: resetEmail)
                showResetSent = true
                showPasswordReset = false
                errorMessage = ""
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }

    private func loginUser() async throws {
        try await authManager.signIn(email: email, password: password)
    }

    private func createUser() async throws {
        try await authManager.createUser(email: email, password: password)
    }
}

// MARK: - Requirement Row Component

private struct RequirementRow: View {
    let isMet: Bool
    let text: String

    var body: some View {
        HStack {
            Image(systemName: isMet ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(isMet ? .green : .red)
                .imageScale(.small)
            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

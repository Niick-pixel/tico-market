import SwiftUI

struct SignInView: View {
    @EnvironmentObject var authService: AuthService
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?
    @State private var isLoading = false
    @State private var showSignUp = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()

                VStack(spacing: 6) {
                    Text("Tico Market")
                        .font(.largeTitle.bold())
                    Text("Comprá, vendé y ofertá en Costa Rica")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                VStack(spacing: 14) {
                    TextField("Correo electrónico", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .padding()
                        .glassCard(cornerRadius: 14)

                    SecureField("Contraseña", text: $password)
                        .textContentType(.password)
                        .padding()
                        .glassCard(cornerRadius: 14)
                }

                if let errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }

                Button {
                    Task { await signIn() }
                } label: {
                    if isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Iniciar sesión")
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.primaryGlass)
                .disabled(email.isEmpty || password.isEmpty || isLoading)

                Button("¿No tenés cuenta? Creá una") {
                    showSignUp = true
                }
                .font(.footnote)

                Spacer()
                Spacer()
            }
            .padding()
            .sheet(isPresented: $showSignUp) {
                SignUpView()
            }
        }
    }

    private func signIn() async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }
        do {
            try await authService.signIn(email: email, password: password)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

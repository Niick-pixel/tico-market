import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authService: AuthService
    @Environment(\.dismiss) private var dismiss

    @State private var displayName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?
    @State private var isLoading = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 14) {
                TextField("Nombre completo", text: $displayName)
                    .padding()
                    .glassCard(cornerRadius: 14)

                TextField("Correo electrónico", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .padding()
                    .glassCard(cornerRadius: 14)

                SecureField("Contraseña (mínimo 6 caracteres)", text: $password)
                    .textContentType(.newPassword)
                    .padding()
                    .glassCard(cornerRadius: 14)

                if let errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }

                Button {
                    Task { await signUp() }
                } label: {
                    if isLoading {
                        ProgressView().frame(maxWidth: .infinity)
                    } else {
                        Text("Crear cuenta").frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.primaryGlass)
                .disabled(displayName.isEmpty || email.isEmpty || password.count < 6 || isLoading)

                Spacer()
            }
            .padding()
            .navigationTitle("Crear cuenta")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
            }
        }
    }

    private func signUp() async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }
        do {
            try await authService.signUp(email: email, password: password, displayName: displayName)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

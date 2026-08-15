import SwiftUI

struct ProfileView: View {
    var previewMode: Bool = false

    @EnvironmentObject var authService: AuthService

    private var displayProfile: UserProfile? {
        previewMode ? PreviewData.profile : authService.userProfile
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                VStack(spacing: 8) {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(.secondary)
                    Text(displayProfile?.displayName ?? "Usuario")
                        .font(.title3.bold())
                    Text(displayProfile?.email ?? "")
                        .font(.footnote)
                        .foregroundStyle(.secondary)

                    if let profile = displayProfile, profile.ratingCount > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill").foregroundStyle(.yellow)
                            Text(String(format: "%.1f (%d)", profile.rating, profile.ratingCount))
                                .font(.caption)
                        }
                    }
                }
                .padding()
                .glassCard(cornerRadius: 20)
                .padding(.horizontal)

                Spacer()

                Button(role: .destructive) {
                    try? authService.signOut()
                } label: {
                    Text("Cerrar sesión")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
            .navigationTitle("Perfil")
        }
    }
}

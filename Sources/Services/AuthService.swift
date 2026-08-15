import Foundation
import FirebaseAuth
import FirebaseFirestore

@MainActor
final class AuthService: ObservableObject {
    @Published var currentUser: User?
    @Published var userProfile: UserProfile?
    @Published var isLoading = true

    private var authHandle: AuthStateDidChangeListenerHandle?
    private let db = Firestore.firestore()

    init() {
        authHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self else { return }
            self.currentUser = user
            Task {
                if let user {
                    await self.loadProfile(uid: user.uid)
                } else {
                    self.userProfile = nil
                }
                self.isLoading = false
            }
        }
    }

    deinit {
        if let authHandle {
            Auth.auth().removeStateDidChangeListener(authHandle)
        }
    }

    func signUp(email: String, password: String, displayName: String) async throws {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)

        let changeRequest = result.user.createProfileChangeRequest()
        changeRequest.displayName = displayName
        try await changeRequest.commitChanges()

        let profile = UserProfile(
            displayName: displayName,
            email: email,
            phoneNumber: nil,
            location: nil,
            rating: 0,
            ratingCount: 0,
            createdAt: Date()
        )
        try db.collection("users").document(result.user.uid).setData(from: profile)
        userProfile = profile
    }

    func signIn(email: String, password: String) async throws {
        try await Auth.auth().signIn(withEmail: email, password: password)
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }

    private func loadProfile(uid: String) async {
        do {
            let snapshot = try await db.collection("users").document(uid).getDocument()
            userProfile = try snapshot.data(as: UserProfile.self)
        } catch {
            print("No se pudo cargar el perfil: \(error)")
        }
    }
}

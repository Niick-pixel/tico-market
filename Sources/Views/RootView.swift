import SwiftUI

struct RootView: View {
    @EnvironmentObject var authService: AuthService

    var body: some View {
        Group {
            if authService.isLoading {
                ProgressView()
            } else if authService.currentUser != nil {
                MainTabView()
            } else {
                SignInView()
            }
        }
        .animation(.default, value: authService.currentUser?.uid)
    }
}

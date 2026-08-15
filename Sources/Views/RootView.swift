import SwiftUI

struct RootView: View {
    @EnvironmentObject var authService: AuthService

    /// Lets CI (and local Xcode runs) see the signed-in screens with sample
    /// data, without a real Firebase project to authenticate against. Set via
    /// `SIMCTL_CHILD_UI_PREVIEW_MODE=1` when launching through simctl.
    private var isPreviewMode: Bool {
        ProcessInfo.processInfo.environment["UI_PREVIEW_MODE"] == "1"
    }

    var body: some View {
        Group {
            if isPreviewMode {
                MainTabView(previewMode: true)
            } else if authService.isLoading {
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

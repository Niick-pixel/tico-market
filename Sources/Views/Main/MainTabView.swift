import SwiftUI

struct MainTabView: View {
    var previewMode: Bool = false

    var body: some View {
        TabView {
            HomeView(previewMode: previewMode)
                .tabItem { Label("Inicio", systemImage: "house.fill") }

            CreateListingView()
                .tabItem { Label("Publicar", systemImage: "plus.circle.fill") }

            ProfileView(previewMode: previewMode)
                .tabItem { Label("Perfil", systemImage: "person.fill") }
        }
    }
}

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Inicio", systemImage: "house.fill") }

            CreateListingView()
                .tabItem { Label("Publicar", systemImage: "plus.circle.fill") }

            ProfileView()
                .tabItem { Label("Perfil", systemImage: "person.fill") }
        }
    }
}

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var settings: AppSettings

    var body: some View {
        TabView {
            CatalogView()
                .tabItem {
                    Label("Catalogue", systemImage: "film")
                }

            SearchView()
                .tabItem {
                    Label("Recherche", systemImage: "magnifyingglass")
                }

            SettingsView()
                .tabItem {
                    Label("Réglages", systemImage: "gearshape")
                }
        }
        .tint(.purple)
    }
}

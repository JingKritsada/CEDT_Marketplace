import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var session: SessionViewModel

    var body: some View {
        ZStack {
            Color(.systemGray6)
                .ignoresSafeArea()

            Group {
                if session.isAuthenticated {
                    MainTabView()
                } else {
                    OnboardingView()
                }
            }
        }
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }

            PostItemView()
                .tabItem {
                    Label("Post", systemImage: "plus.circle")
                }

            WishlistView()
                .tabItem {
                    Label("Wishlist", systemImage: "heart")
                }

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }
        .tint(.accentPrimary)
        .background(Color.clear)
    }
}

#Preview {
    ContentView()
        .environmentObject(SessionViewModel())
}

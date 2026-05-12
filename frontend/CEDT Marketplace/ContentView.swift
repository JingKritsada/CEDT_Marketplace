import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var session: SessionViewModel

    var body: some View {
        Group {
            if session.isAuthenticated {
                MainTabView()
            } else {
                OnboardingView()
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

            CartView()
                .tabItem {
                    Label("Cart", systemImage: "cart")
                }

            NotificationView()
                .tabItem {
                    Label("Alerts", systemImage: "bell")
                }

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }
        .tint(.accentPrimary)
    }
}

#Preview {
    ContentView()
        .environmentObject(SessionViewModel())
}

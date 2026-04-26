import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Tab = .home
    @StateObject private var navManager = NavigationManager()
    @State private var isAuthenticated = UserDefaults.standard.string(forKey: "user_token") != nil
    
    init() {
        UITabBar.appearance().isHidden = true
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case .home:
                    HomeView()
                case .post:
                    CreateListingView(selectedTab: $selectedTab)
                case .cart:
                    Text("Cart View")
                case .alerts:
                    Text("Alerts View") 
                case .profile:
                    Button("Logout (Test)") {
                        UserDefaults.standard.removeObject(forKey: "user_token")
                        withAnimation {
                            isAuthenticated = false
                        }
                    }
                    .foregroundColor(.red)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            if !navManager.isTabBarHidden {
                CustomTabBar(selectedTab: $selectedTab)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("UserUnauthorized"))) { _ in
            withAnimation {
                self.isAuthenticated = false // เปลี่ยนสถานะปุ๊บ หน้า Login จะโผล่ปั๊บ
            }
        }
        .fullScreenCover(isPresented: .init(get: { !isAuthenticated }, set: { _ in })) {
            AuthContainerView {
                withAnimation { isAuthenticated = true }
            }
        }
        .environmentObject(navManager)
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

enum Tab: String, CaseIterable {
    case home = "HOME"
    case post = "POST"
    case cart = "CART"
    case alerts = "ALERTS"
    case profile = "PROFILE"
    
    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .post: return "plus.circle"
        case .cart: return "cart"
        case .alerts: return "bell"
        case .profile: return "person"
        }
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: Tab
    
    
    var body: some View {
        HStack {
            ForEach(Tab.allCases, id: \.self) { tab in
                Spacer()
                Button {
                    withAnimation(.spring()) {
                        selectedTab = tab
                    }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 16))
                        
                        Text(tab.rawValue)
                            .font(.system(size: 8, weight: .bold))
                    }
                    .foregroundColor(selectedTab == tab ? .pink : .secondary)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(
                        selectedTab == tab ? Color.pink.opacity(0.1) : Color.clear
                    )
                    .cornerRadius(20)
                }
                Spacer()
            }
        }
        .padding(.top, 12)
        .padding(.bottom, 5)
        .background(Color.white.shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: -5)
            .ignoresSafeArea(edges: .bottom))
        .clipShape(RoundedCorner(radius: 30, corners: [.topLeft, .topRight]))
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: -5)
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

#Preview {
	ContentView()
}

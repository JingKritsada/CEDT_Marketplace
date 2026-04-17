import SwiftUI

struct ContentView: View {
    // ในอนาคต (Commit 10) เราจะเพิ่ม Logic เช็คสถานะการ Login ที่นี่ครับ
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Market", systemImage: "house.fill")
                }

            Text("Create Listing (Coming Soon)")
                .tabItem {
                    Label("Sell", systemImage: "plus.circle.fill")
                }

            Text("Profile & Settings (Coming Soon)")
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
        .accentColor(.pink)
    }
}

//
//  CEDT_MarketplaceApp.swift
//  CEDT Marketplace
//
//  Created by Kritsada Limsripraphan on 18/4/2569 BE.
//

import SwiftUI

@main
struct CEDT_MarketplaceApp: App {
    @StateObject private var session = SessionViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(session)
        }
    }
}

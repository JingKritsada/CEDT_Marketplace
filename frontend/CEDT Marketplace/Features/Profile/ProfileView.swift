//
//  ProfileView.swift
//  CEDT Marketplace
//
//  Created by Phachara Charoenkitkul on 1/5/2569 BE.
//

import SwiftUI

struct ProfileView: View {
    @StateObject private var userViewModel = UserViewModel()
    @EnvironmentObject var navManager: NavigationManager

    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                headerSection() // ฟังก์ชันที่สร้างไว้ในไฟล์นี้
                ProfileHeader(user: userViewModel.currentUser)
                ProfileStatsRow()
                ItemHistoryGrid()
                StudentStatusBanner()
                reviewsSection()
            }
            .padding(.bottom, 100)
        }
        .background(Color(.systemGray6).opacity(0.3))
        .onAppear {
            Task { await userViewModel.fetchMe() }
        }
    }
    private func headerSection() -> some View {
        HStack {
            Text("Profile")
                .font(.title).bold()
                .foregroundColor(.pink)
            Spacer()
            Button(action: {}) {
                Image(systemName: "gearshape")
                    .font(.title3)
                    .foregroundColor(.primary)
            }
        }
        .padding(.horizontal, 25)
        .padding(.top, 20)
    }

    private func reviewsSection() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "star.square")
                    .foregroundColor(.pink)
                Text("REVIEWS").font(.caption).bold().foregroundColor(.secondary)
            }
            Text("28 Received").font(.headline)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(15)
        .padding(.horizontal)
    }
}

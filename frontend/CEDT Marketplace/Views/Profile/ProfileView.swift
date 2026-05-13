import Combine
import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var session: SessionViewModel
    @StateObject private var viewModel = ProfileViewModel()
    @State private var lineId = ""
    @State private var instagram = ""
    @State private var facebookUrl = ""

    var body: some View {
        NavigationStack {
            Form {
                if let profile = viewModel.profile {
                    Section("Profile") {
                        Text(profile.displayName)
                            .font(.headline)
                        Text(profile.email)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        if let studentId = profile.studentId {
                            Text("Student ID: \(studentId)")
                                .font(.caption)
                        }
                        HStack(spacing: 6) {
                            RatingStarsView(rating: profile.rating.average)
                            Text("(\(profile.rating.count))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    Section("Social Links") {
                        TextField("LINE ID", text: $lineId)
                        TextField("Instagram", text: $instagram)
                        TextField("Facebook URL", text: $facebookUrl)
                        Button("Save") {
                            Task { await viewModel.updateSocialLinks(lineId: lineId, instagram: instagram, facebookUrl: facebookUrl) }
                        }
                    }

                    Section("Your Listings") {
                        NavigationLink("Posted Items") {
                            PostedItemsView(listings: viewModel.postedListings)
                        }
                        NavigationLink("Purchased Items") {
                            PurchasedItemsView(listings: viewModel.purchasedListings)
                        }
                        NavigationLink("Sold Items") {
                            SoldItemsView(listings: viewModel.soldListings)
                        }
                        NavigationLink("Confirmed Items") {
                            ConfirmedItemsView(listings: viewModel.confirmedListings)
                        }
                        NavigationLink("Post Item") {
                            PostItemView()
                        }
                    }
                } else if viewModel.isLoading {
                    ProgressView()
                } else {
                    EmptyStateView(title: "No profile", message: "Please try again later.")
                }

                Section {
                    Button("Log out", role: .destructive) {
                        session.logout()
                    }
                }
            }
            .navigationTitle("Profile")
            .scrollContentBackground(.hidden)
            .background(Color(.systemGray6))
            .task {
                await viewModel.loadProfile()
                if let profile = viewModel.profile {
                    lineId = profile.lineId ?? ""
                    instagram = profile.instagram ?? ""
                    facebookUrl = profile.facebookUrl ?? ""
                }
            }
        }
        .background(Color(.systemGray6))
    }
}

#Preview {
    ProfileView()
        .environmentObject(SessionViewModel())
}

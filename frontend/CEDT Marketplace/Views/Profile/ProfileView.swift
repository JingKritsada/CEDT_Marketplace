import Combine
import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var session: SessionViewModel
    @StateObject private var viewModel = ProfileViewModel()

    @State private var lineId = ""
    @State private var instagram = ""
    @State private var facebookUrl = ""
    @State private var showLogoutAlert = false

    private let cardCornerRadius: CGFloat = 24

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    if let profile = viewModel.profile {
                        heroCard(profile)
                        SellerDashboardCard(viewModel: viewModel)
                        socialLinksCard
                        myListingsCard
                        logoutCard
                    } else if viewModel.isLoading {
                        ProgressView()
                            .scaleEffect(1.5)
                            .frame(maxWidth: .infinity, minHeight: 240)
                    } else {
                        EmptyStateView(
                            title: "No profile",
                            message: "We couldn't load your profile. Pull to refresh."
                        )
                        .frame(minHeight: 320)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 32)
            }
            .background(Color(.systemGray6))
            .navigationTitle("Profile")
            .task {
                await viewModel.loadProfile()
                if let profile = viewModel.profile {
                    lineId = profile.lineId ?? ""
                    instagram = profile.instagram ?? ""
                    facebookUrl = profile.facebookUrl ?? ""
                }
            }
            .refreshable { await viewModel.loadProfile() }
            .sheet(item: Binding<IdentifiableURL?>(
                get: { viewModel.onboardingURL.map { IdentifiableURL(url: $0) } },
                set: { viewModel.onboardingURL = $0?.url }
            )) { wrapper in
                NavigationStack {
                    SafariView(url: wrapper.url)
                        .ignoresSafeArea()
                        .navigationTitle("Seller onboarding")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button("Done") { viewModel.onboardingURL = nil }
                            }
                        }
                }
                .onDisappear {
                    // After the buyer finishes (or aborts) Stripe onboarding, force-pull
                    // the latest status from the backend so the UI reflects reality.
                    Task { await viewModel.refreshSellerStatus() }
                }
            }
            .onChange(of: viewModel.errorMessage) { _, newValue in
                guard let message = newValue, !message.isEmpty else { return }
                LocalNotifier.error(message)
                viewModel.errorMessage = nil
            }
        }
        .background(Color(.systemGray6))
    }

    // MARK: - Hero

    private func heroCard(_ profile: UserProfile) -> some View {
        VStack(spacing: 16) {
            avatar(profile)

            VStack(spacing: 4) {
                Text(profile.displayName)
                    .font(.title2.weight(.bold))
                    .foregroundColor(.primary)

                Text(profile.email)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            HStack(spacing: 24) {
                if let studentId = profile.studentId {
                    metaPill(systemImage: "graduationcap", value: studentId)
                }
                metaPill(
                    systemImage: "star.fill",
                    value: String(format: "%.1f (%d)", profile.rating.average, profile.rating.count),
                    tint: .yellow
                )
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .padding(.horizontal, 20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous))
    }

    private func avatar(_ profile: UserProfile) -> some View {
        Group {
            if let avatarUrl = profile.avatarUrl,
               let url = URL(string: avatarUrl.trimmingCharacters(in: .whitespacesAndNewlines)),
               url.scheme?.hasPrefix("http") == true
            {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case let .success(image):
                        image.resizable().scaledToFill()
                    default:
                        initialsAvatar(profile.displayName)
                    }
                }
            } else {
                initialsAvatar(profile.displayName)
            }
        }
        .frame(width: 88, height: 88)
        .clipShape(Circle())
        .overlay(
            Circle().strokeBorder(Color.accentPrimary.opacity(0.2), lineWidth: 3)
        )
        .shadow(color: .black.opacity(0.08), radius: 12, y: 6)
    }

    private func initialsAvatar(_ name: String) -> some View {
        ZStack {
            LinearGradient(
                colors: [.accentPrimary, .accentSecondary],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            Text(initials(from: name))
                .font(.title.weight(.bold))
                .foregroundColor(.white)
        }
    }

    private func initials(from name: String) -> String {
        let pieces = name.split(separator: " ").prefix(2)
        let letters = pieces.compactMap(\.first).map(String.init)
        return letters.isEmpty ? "?" : letters.joined().uppercased()
    }

    private func metaPill(systemImage: String, value: String, tint: Color = .accentPrimary)
        -> some View
    {
        HStack(spacing: 6) {
            Image(systemName: systemImage)
                .font(.caption.weight(.semibold))
                .foregroundColor(tint)

            Text(value)
                .font(.caption.weight(.semibold))
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(tint.opacity(0.12))
        .clipShape(Capsule())
    }

    // MARK: - Social links

    private var socialLinksCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Social links", systemImage: "link")
                .font(.headline)
                .foregroundColor(.primary)

            stackedField(label: "LINE ID", placeholder: "@your-line-id", text: $lineId)
            stackedField(
                label: "Instagram", placeholder: "https://instagram.com/...",
                text: $instagram, keyboardType: .URL
            )
            stackedField(
                label: "Facebook URL", placeholder: "https://facebook.com/...",
                text: $facebookUrl, keyboardType: .URL
            )

            PrimaryButton(
                title: "Save",
                action: {
                    Task {
                        await viewModel.updateSocialLinks(
                            lineId: lineId, instagram: instagram, facebookUrl: facebookUrl
                        )
                        if viewModel.errorMessage == nil {
                            LocalNotifier.success(
                                "Social links updated.", title: "Profile saved"
                            )
                        }
                    }
                },
                paddingSize: 6,
                isLoading: viewModel.isLoading
            )
            .font(.subheadline.weight(.semibold))
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous))
    }

    private func stackedField(
        label: String,
        placeholder: String,
        text: Binding<String>,
        keyboardType: UIKeyboardType = .default
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label.uppercased())
                .font(.caption.weight(.semibold))
                .foregroundColor(.secondary)

            TextField(placeholder, text: text)
                .keyboardType(keyboardType)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .padding(.horizontal, 14)
                .padding(.vertical, 14)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
    }

    // MARK: - Listings nav

    private var myListingsCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            Label("My listings", systemImage: "square.stack.3d.up")
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.bottom, 8)

            navRow(
                title: "Posted Items",
                subtitle: "\(viewModel.postedListings.count) item\(viewModel.postedListings.count == 1 ? "" : "s")",
                systemImage: "tag.fill", tint: .accentPrimary
            ) {
                PostedItemsView(viewModel: viewModel)
            }

            Divider().padding(.vertical, 6)

            navRow(
                title: "Purchased Items",
                subtitle: "\(viewModel.purchasedListings.count) item\(viewModel.purchasedListings.count == 1 ? "" : "s")",
                systemImage: "bag.fill", tint: .statusInfo
            ) {
                PurchasedItemsView(viewModel: viewModel)
            }

            Divider().padding(.vertical, 6)

            navRow(
                title: "Sold Items",
                subtitle: "\(viewModel.soldListings.count) item\(viewModel.soldListings.count == 1 ? "" : "s")",
                systemImage: "checkmark.seal.fill", tint: .statusAvailable
            ) {
                SoldItemsView(viewModel: viewModel)
            }

            Divider().padding(.vertical, 6)

            navRow(
                title: "Confirmed Items",
                subtitle: "\(viewModel.confirmedListings.count) item\(viewModel.confirmedListings.count == 1 ? "" : "s")",
                systemImage: "shippingbox.fill", tint: .statusReserved
            ) {
                ConfirmedItemsView(viewModel: viewModel)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous))
    }

    private func navRow(
        title: String, subtitle: String, systemImage: String, tint: Color,
        @ViewBuilder destination: () -> some View
    ) -> some View {
        NavigationLink(destination: destination()) {
            HStack(spacing: 14) {
                ZStack {
                    Circle().fill(tint.opacity(0.15))
                        .frame(width: 40, height: 40)
                    Image(systemName: systemImage)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(tint)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.primary)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Logout

    private var logoutCard: some View {
        Button(role: .destructive) {
            showLogoutAlert = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.subheadline.weight(.semibold))
                Text("Log out")
                    .font(.subheadline.weight(.semibold))
                Spacer()
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(Color(.systemBackground))
            .foregroundColor(.red)
            .clipShape(RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous))
        }
        .alert("Log out?", isPresented: $showLogoutAlert) {
            Button("Log out", role: .destructive) { session.logout() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("You'll need to sign in again to use the app.")
        }
    }
}

/// Wrapper to avoid retroactive conformance on `URL`.
private struct IdentifiableURL: Identifiable {
    let url: URL
    var id: String {
        url.absoluteString
    }
}

#Preview {
    ProfileView()
        .environmentObject(SessionViewModel())
}

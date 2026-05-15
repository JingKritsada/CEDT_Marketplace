import Combine
import PhotosUI
import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var session: SessionViewModel
    @StateObject private var viewModel = ProfileViewModel()

    // Hero edit state
    @State private var isEditingProfile = false
    @State private var editDisplayName = ""
    @State private var avatarPickerItem: PhotosPickerItem?
    @State private var pendingAvatarData: Data?
    @State private var pendingAvatarImage: UIImage?

    // Social links edit state
    @State private var isEditingSocials = false
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
                seedEditFields()
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
                    Task { await viewModel.refreshSellerStatus() }
                }
            }
            .onChange(of: viewModel.errorMessage) { _, newValue in
                guard let message = newValue, !message.isEmpty else { return }
                LocalNotifier.error(message)
                viewModel.errorMessage = nil
            }
            .onChange(of: avatarPickerItem) { _, newItem in
                Task {
                    guard let newItem,
                          let data = try? await newItem.loadTransferable(type: Data.self),
                          let uiImage = UIImage(data: data) else { return }
                    pendingAvatarData = data
                    pendingAvatarImage = uiImage
                }
            }
        }
        .background(Color(.systemGray6))
    }

    // MARK: - Helpers

    private func seedEditFields() {
        guard let profile = viewModel.profile else { return }
        editDisplayName = profile.displayName
        lineId = profile.lineId ?? ""
        instagram = profile.instagram ?? ""
        facebookUrl = profile.facebookUrl ?? ""
    }

    // MARK: - Hero card

    private func heroCard(_ profile: UserProfile) -> some View {
        VStack(spacing: 16) {
            if isEditingProfile {
                heroEditContent(profile)
            } else {
                heroReadContent(profile)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .padding(.horizontal, 20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous))
        .animation(.easeInOut(duration: 0.2), value: isEditingProfile)
    }

    private func heroReadContent(_ profile: UserProfile) -> some View {
        VStack(spacing: 16) {
            ZStack(alignment: .bottomTrailing) {
                avatar(profile)
            }

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

            Button {
                editDisplayName = profile.displayName
                pendingAvatarData = nil
                pendingAvatarImage = nil
                isEditingProfile = true
            } label: {
                Label("Edit profile", systemImage: "pencil")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.accentPrimary)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(Color.accentPrimary.opacity(0.1))
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
    }

    private func heroEditContent(_ profile: UserProfile) -> some View {
        VStack(spacing: 20) {
            // Avatar picker
            PhotosPicker(selection: $avatarPickerItem, matching: .images) {
                ZStack(alignment: .bottomTrailing) {
                    Group {
                        if let uiImage = pendingAvatarImage {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                        } else {
                            avatar(profile)
                        }
                    }
                    .frame(width: 88, height: 88)
                    .clipShape(Circle())
                    .overlay(Circle().strokeBorder(Color.accentPrimary.opacity(0.3), lineWidth: 2))

                    Circle()
                        .fill(Color.accentPrimary)
                        .frame(width: 28, height: 28)
                        .overlay(
                            Image(systemName: "camera.fill")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.white)
                        )
                        .offset(x: 4, y: 4)
                }
            }
            .buttonStyle(.plain)

            // Display name field
            VStack(alignment: .leading, spacing: 6) {
                Text("DISPLAY NAME")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.secondary)

                TextField("Display name", text: $editDisplayName)
                    .textInputAutocapitalization(.words)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Save / Cancel
            HStack(spacing: 12) {
                Button("Cancel") {
                    isEditingProfile = false
                    pendingAvatarData = nil
                    pendingAvatarImage = nil
                }
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.secondary)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .buttonStyle(.plain)

                PrimaryButton(
                    title: "Save",
                    action: {
                        Task {
                            let name = editDisplayName.trimmingCharacters(in: .whitespaces)
                            guard !name.isEmpty else { return }
                            await viewModel.updateDisplayInfo(
                                displayName: name,
                                avatarData: pendingAvatarData
                            )
                            if viewModel.errorMessage == nil {
                                isEditingProfile = false
                                pendingAvatarData = nil
                                pendingAvatarImage = nil
                                LocalNotifier.success("Profile updated.", title: "Saved")
                            }
                        }
                    },
                    paddingSize: 10,
                    isLoading: viewModel.isLoading
                )
                .font(.subheadline.weight(.semibold))
            }
        }
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
            HStack {
                Label("Social links", systemImage: "link")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                if !isEditingSocials {
                    Button {
                        isEditingSocials = true
                    } label: {
                        Label("Edit", systemImage: "pencil")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.accentPrimary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.accentPrimary.opacity(0.1))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }

            if isEditingSocials {
                socialEditFields

                HStack(spacing: 12) {
                    Button("Cancel") {
                        guard let profile = viewModel.profile else { return }
                        lineId = profile.lineId ?? ""
                        instagram = profile.instagram ?? ""
                        facebookUrl = profile.facebookUrl ?? ""
                        isEditingSocials = false
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .buttonStyle(.plain)

                    PrimaryButton(
                        title: "Save",
                        action: {
                            Task {
                                await viewModel.updateSocialLinks(
                                    lineId: lineId.isEmpty ? nil : lineId,
                                    instagram: instagram.isEmpty ? nil : instagram,
                                    facebookUrl: facebookUrl.isEmpty ? nil : facebookUrl
                                )
                                if viewModel.errorMessage == nil {
                                    isEditingSocials = false
                                    LocalNotifier.success("Social links updated.", title: "Saved")
                                }
                            }
                        },
                        paddingSize: 10,
                        isLoading: viewModel.isLoading
                    )
                    .font(.subheadline.weight(.semibold))
                }
            } else {
                socialReadRows
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous))
        .animation(.easeInOut(duration: 0.2), value: isEditingSocials)
    }

    private var socialReadRows: some View {
        VStack(spacing: 0) {
            socialReadRow(icon: "message.fill", label: "LINE", value: lineId, color: .green)
            Divider().padding(.vertical, 8)
            socialReadRow(icon: "camera.fill", label: "Instagram", value: instagram, color: .purple)
            Divider().padding(.vertical, 8)
            socialReadRow(icon: "person.2.fill", label: "Facebook", value: facebookUrl, color: .blue)
        }
    }

    private func socialReadRow(icon: String, label: String, value: String, color: Color) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle().fill(color.opacity(0.12)).frame(width: 32, height: 32)
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(color)
            }
            Text(label)
                .font(.subheadline.weight(.medium))
                .foregroundColor(.primary)
            Spacer()
            Text(value.isEmpty ? "Not set" : value)
                .font(.subheadline)
                .foregroundColor(value.isEmpty ? .secondary.opacity(0.6) : .secondary)
                .lineLimit(1)
                .truncationMode(.middle)
        }
    }

    private var socialEditFields: some View {
        VStack(spacing: 12) {
            stackedField(label: "LINE ID", placeholder: "@your-line-id", text: $lineId)
            stackedField(
                label: "Instagram",
                placeholder: "https://instagram.com/...",
                text: $instagram,
                keyboardType: .URL
            )
            stackedField(
                label: "Facebook URL",
                placeholder: "https://facebook.com/...",
                text: $facebookUrl,
                keyboardType: .URL
            )
        }
    }

    private func stackedField(
        label: String,
        placeholder: String,
        text: Binding<String>,
        keyboardType: UIKeyboardType = .default
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label.uppercased())
                .font(.caption.weight(.semibold))
                .foregroundColor(.secondary)

            TextField(placeholder, text: text)
                .keyboardType(keyboardType)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
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
            ) { PostedItemsView(viewModel: viewModel) }

            Divider().padding(.vertical, 6)

            navRow(
                title: "Purchased Items",
                subtitle: "\(viewModel.purchasedListings.count) item\(viewModel.purchasedListings.count == 1 ? "" : "s")",
                systemImage: "bag.fill", tint: .statusInfo
            ) { PurchasedItemsView(viewModel: viewModel) }

            Divider().padding(.vertical, 6)

            navRow(
                title: "Sold Items",
                subtitle: "\(viewModel.soldListings.count) item\(viewModel.soldListings.count == 1 ? "" : "s")",
                systemImage: "checkmark.seal.fill", tint: .statusAvailable
            ) { SoldItemsView(viewModel: viewModel) }

            Divider().padding(.vertical, 6)

            navRow(
                title: "Confirmed Items",
                subtitle: "\(viewModel.confirmedListings.count) item\(viewModel.confirmedListings.count == 1 ? "" : "s")",
                systemImage: "shippingbox.fill", tint: .statusReserved
            ) { ConfirmedItemsView(viewModel: viewModel) }
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
                    Circle().fill(tint.opacity(0.15)).frame(width: 40, height: 40)
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

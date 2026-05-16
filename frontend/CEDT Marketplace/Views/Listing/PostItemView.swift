import Combine
import PhotosUI
import SwiftUI
import UIKit
import UserNotifications

struct PostItemView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = PostItemViewModel()

    @State private var showConfirmAlert = false

    private let cardCornerRadius: CGFloat = 24

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    headerSection

                    if viewModel.isLoadingSeller {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                        .padding(.vertical, 8)
                    } else if !viewModel.isSellerActive {
                        sellerGateBanner
                    }

                    Group {
                        ListingImagePickerView(
                            previews: viewModel.imagePreviews,
                            onAdd: { dataItems in viewModel.addImages(from: dataItems) },
                            onRemove: { index in
                                viewModel.removeImage(at: index)
                            }
                        )

                        formCard(title: "Listing details", systemImage: "square.and.pencil") {
                            stackedField(
                                label: "Title", placeholder: "e.g. Raspberry Pi 4 Model B", text: $viewModel.title
                            )
                            multilineField(
                                label: "Description",
                                placeholder: "Mention condition, usage history, and what is included.",
                                text: $viewModel.description
                            )
                        }

                        formCard(title: "Pricing", systemImage: "bahtsign.circle") {
                            Toggle("Free item", isOn: $viewModel.isFree)
                                .tint(.accentPrimary)

                            stackedField(
                                label: "Price",
                                placeholder: "0",
                                text: $viewModel.price,
                                keyboardType: .numberPad,
                                prefix: "฿",
                                isDisabled: viewModel.isFree
                            )
                        }

                        formCard(title: "Item info", systemImage: "tag") {
                            pickerField(
                                label: "Category",
                                selection: $viewModel.selectedCategoryId,
                                placeholder: "Select a category",
                                options: viewModel.categories.map { ($0.id, $0.name) }
                            )

                            pickerField(
                                label: "Pickup location",
                                selection: $viewModel.selectedPickupLocationId,
                                placeholder: "Select a pickup spot",
                                options: viewModel.pickupLocations.map { ($0.id, "\($0.name)") }
                            )

                            pickerField(
                                label: "Condition",
                                selection: Binding(
                                    get: { viewModel.condition.rawValue },
                                    set: { newValue in
                                        if let condition = ListingCondition(rawValue: newValue) {
                                            viewModel.condition = condition
                                        }
                                    }
                                ),
                                placeholder: "Condition",
                                options: ListingCondition.allCases.map { ($0.rawValue, $0.displayName) }
                            )

                            stackedField(label: "Course code", placeholder: "2110101", text: $viewModel.courseCode)
                        }

                        if let errorMessage = viewModel.errorMessage {
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .foregroundColor(.red)

                                Text(errorMessage)
                                    .font(.subheadline)
                                    .foregroundColor(.red)
                            }
                        }

                        PrimaryButton(
                            title: "Post Item",
                            action: {
                                if viewModel.validate() {
                                    showConfirmAlert = true
                                }
                            },
                            isLoading: viewModel.isLoading
                        )
                    }
                    .disabled(!viewModel.isSellerActive)
                    .opacity(viewModel.isSellerActive ? 1 : 0.4)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 32)
            }
            .background(Color(.systemGray6))
            .toolbar(.hidden, for: .navigationBar)
            .refreshable {
                viewModel.resetForm()
                await viewModel.loadSellerStatus()
                await viewModel.loadOptions()
            }
            .task {
                await viewModel.loadSellerStatus()
                await viewModel.loadOptions()
            }
            .onChange(of: viewModel.isFree) { _, isFree in
                if isFree {
                    viewModel.price = "0"
                }
            }
            .alert("Post this item?", isPresented: $showConfirmAlert) {
                Button("Post", role: .none) {
                    Task {
                        if await viewModel.submitListing() != nil {
                            LocalNotifier.success(
                                "Your listing is now live on the marketplace.", title: "Item posted"
                            )
                            viewModel.resetForm()
                            try? await Task.sleep(for: .seconds(0.5))
                            dismiss()
                        } else {
                            LocalNotifier.error(
                                viewModel.errorMessage ?? "Something went wrong. Please try again.",
                                title: "Posting failed"
                            )
                        }
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Your listing will be visible to others on the marketplace.")
            }
        }
        .background(Color(.systemGray6))
    }

    private var sellerGateBanner: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "storefront")
                    .font(.title2)
                    .foregroundColor(.accentColor)

                Text("Seller account required")
                    .font(.headline)
                    .foregroundColor(.primary)
            }

            Text(sellerGateBannerMessage)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous)
                .strokeBorder(Color.accentColor.opacity(0.35), lineWidth: 1.5)
        )
    }

    private var sellerGateBannerMessage: String {
        switch viewModel.sellerProfile?.connectStatus {
        case .pending:
            "Your seller account is under review. You'll be able to post listings once verification is complete."
        case .restricted:
            "Your Stripe account needs attention. Please complete the required steps in your profile to start selling."
        case .rejected:
            "Your seller application was not approved. Visit your profile for more details."
        default:
            "To post listings, you need to register as a seller and complete Stripe onboarding. Head to your profile to get started."
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("List something useful.")
                .font(.largeTitle.bold())
                .foregroundColor(.primary)
            Text("Add photos, fill in the blank, and publish it.")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.bottom, 2)
    }

    private func formCard(
        title: String, systemImage: String, @ViewBuilder content: () -> some View
    ) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Label(title, systemImage: systemImage)
                .font(.headline)
                .foregroundColor(.primary)

            content()
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous))
    }

    private func stackedField(
        label: String,
        placeholder: String,
        text: Binding<String>,
        keyboardType: UIKeyboardType = .default,
        prefix: String? = nil,
        isDisabled: Bool = false
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label.uppercased())
                .font(.caption.weight(.semibold))
                .foregroundColor(.secondary)

            HStack(spacing: 10) {
                if let prefix {
                    Text(prefix)
                        .font(.headline)
                        .foregroundColor(.secondary)
                }

                TextField(placeholder, text: text)
                    .keyboardType(keyboardType)
                    .textInputAutocapitalization(.sentences)
                    .autocorrectionDisabled()
                    .disabled(isDisabled)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .opacity(isDisabled ? 0.55 : 1)
        }
    }

    private func multilineField(label: String, placeholder: String, text: Binding<String>)
        -> some View
    {
        VStack(alignment: .leading, spacing: 8) {
            Text(label.uppercased())
                .font(.caption.weight(.semibold))
                .foregroundColor(.secondary)

            ZStack(alignment: .topLeading) {
                if text.wrappedValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text(placeholder)
                        .foregroundColor(.secondary.opacity(0.55))
                        .padding(.top, 14)
                        .padding(.horizontal, 18)
                }

                TextEditor(text: text)
                    .frame(minHeight: 120)
                    .scrollContentBackground(.hidden)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 10)
            }
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
    }

    private func pickerField(
        label: String,
        selection: Binding<String?>,
        placeholder: String,
        options: [(String, String)]
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label.uppercased())
                .font(.caption.weight(.semibold))
                .foregroundColor(.secondary)

            Menu {
                Button(placeholder) { selection.wrappedValue = nil }
                ForEach(options, id: \.0) { id, title in
                    Button {
                        selection.wrappedValue = id
                    } label: {
                        if selection.wrappedValue == id {
                            Label(title, systemImage: "checkmark")
                        } else {
                            Text(title)
                        }
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    Text(options.first(where: { $0.0 == selection.wrappedValue })?.1 ?? placeholder)
                        .foregroundColor(selection.wrappedValue == nil ? Color(.placeholderText) : .accentColor)

                    Spacer(minLength: 0)

                    Image(systemName: "chevron.up.chevron.down")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.accentColor)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 14)
                .frame(maxWidth: .infinity)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
        }
    }

    private func pickerField(
        label: String,
        selection: Binding<String>,
        placeholder: String,
        options: [(String, String)]
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label.uppercased())
                .font(.caption.weight(.semibold))
                .foregroundColor(.secondary)

            Menu {
                ForEach(options, id: \.0) { id, title in
                    Button {
                        selection.wrappedValue = id
                    } label: {
                        if selection.wrappedValue == id {
                            Label(title, systemImage: "checkmark")
                        } else {
                            Text(title)
                        }
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    Text(options.first(where: { $0.0 == selection.wrappedValue })?.1 ?? placeholder)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .foregroundColor(.accentColor)

                    Spacer(minLength: 0)

                    Image(systemName: "chevron.up.chevron.down")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.accentColor)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 14)
                .frame(maxWidth: .infinity)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
        }
    }
}

#Preview {
    NavigationStack {
        PostItemView()
    }
}

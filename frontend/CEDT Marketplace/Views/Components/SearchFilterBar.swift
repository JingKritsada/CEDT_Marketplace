import SwiftUI

/// Reusable search bar with optional filter button and horizontal category chips.
/// Used by HomeView and WishlistView.
struct SearchFilterBar: View {
    // MARK: - Config

    let placeholder: String
    @Binding var searchText: String
    @Binding var selectedCategoryId: String?
    let categories: [Category]

    /// Called when the user taps the filter icon. Pass `nil` to hide the button.
    var onFilterTap: (() -> Void)?

    /// Called when the user submits the search field (return key).
    var onSubmit: (() -> Void)?

    /// Label for the "select all" chip.
    var allLabel: String = "All"

    /// Optional destructive trailing action (e.g. "Clear" for wishlist).
    var onTrailingAction: (() -> Void)?
    var trailingActionLabel: String = "Clear"

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                searchField
                if let onFilterTap {
                    filterButton(action: onFilterTap)
                }
                if let onTrailingAction {
                    trailingActionButton(action: onTrailingAction)
                }
            }

            if !categories.isEmpty {
                categoryChips
            }
        }
    }

    // MARK: - Sub-views

    private var searchField: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.secondary)

            TextField(placeholder, text: $searchText)
                .submitLabel(.search)
                .onSubmit { onSubmit?() }

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    private func filterButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: "slider.horizontal.3")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.secondary)
                .frame(width: 44, height: 44)
                .background(Color(.systemGray6))
                .cornerRadius(12)
        }
    }

    private func trailingActionButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(trailingActionLabel)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.red)
                .frame(height: 44)
                .padding(.horizontal, 12)
                .background(Color(.systemGray6))
                .cornerRadius(12)
        }
    }

    private var categoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                chip(title: allLabel, isSelected: selectedCategoryId == nil) {
                    selectedCategoryId = nil
                }
                ForEach(categories) { category in
                    chip(title: category.name, isSelected: selectedCategoryId == category.id) {
                        selectedCategoryId = category.id
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }

    private func chip(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? Color.accentColor : Color(.systemGray6))
                .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

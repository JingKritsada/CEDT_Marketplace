import SwiftUI

/// Modal sheet for the buyer to leave a 1–5 star rating + optional comment
/// on a `.received` listing. Presented from `ListingDetailView`.
struct RatingSheet: View {
    let sellerName: String?
    let onSubmit: (Int, String?) async -> Bool

    @Environment(\.dismiss) private var dismiss

    @State private var rating: Int = 0
    @State private var comment: String = ""
    @State private var isSubmitting = false

    private let cardCornerRadius: CGFloat = 24

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    header

                    starsCard

                    commentCard
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 32)
            }
            .background(Color(.systemGray6))
            .navigationTitle("Rate seller")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
            .safeAreaInset(edge: .bottom) {
                submitBar
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("How was the experience?")
                .font(.title2.weight(.bold))
                .foregroundColor(.primary)
            Text(
                sellerName.map { "Share feedback about \($0). Your rating helps other students." }
                    ?? "Share your feedback. Your rating helps other students."
            )
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
    }

    private var starsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Your rating", systemImage: "star.bubble")
                .font(.headline)
                .foregroundColor(.primary)

            HStack(spacing: 8) {
                ForEach(1 ... 5, id: \.self) { index in
                    Button {
                        rating = index
                    } label: {
                        Image(systemName: index <= rating ? "star.fill" : "star")
                            .font(.system(size: 32, weight: .semibold))
                            .foregroundColor(index <= rating ? .yellow : Color(.systemGray3))
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)
                }
            }

            if rating > 0 {
                Text(ratingLabel)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous))
    }

    private var commentCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Comment (optional)", systemImage: "text.bubble")
                .font(.headline)
                .foregroundColor(.primary)

            ZStack(alignment: .topLeading) {
                if comment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text("What stood out about the item or the seller?")
                        .foregroundColor(.secondary.opacity(0.55))
                        .padding(.top, 14)
                        .padding(.horizontal, 18)
                }

                TextEditor(text: $comment)
                    .frame(minHeight: 120)
                    .scrollContentBackground(.hidden)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 10)
            }
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous))
    }

    private var submitBar: some View {
        PrimaryButton(
            title: "Submit Review",
            action: {
                guard rating > 0, !isSubmitting else { return }
                Task {
                    isSubmitting = true
                    let trimmed = comment.trimmingCharacters(in: .whitespacesAndNewlines)
                    let success = await onSubmit(rating, trimmed.isEmpty ? nil : trimmed)
                    isSubmitting = false
                    if success { dismiss() }
                }
            },
            isLoading: isSubmitting
        )
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 16)
        .background(Color(.systemBackground))
        .disabled(rating == 0)
        .opacity(rating == 0 ? 0.55 : 1)
    }

    private var ratingLabel: String {
        switch rating {
        case 1: "Poor"
        case 2: "Fair"
        case 3: "Good"
        case 4: "Very good"
        case 5: "Excellent"
        default: ""
        }
    }
}

#Preview {
    RatingSheet(sellerName: "Nina Student") { _, _ in true }
}

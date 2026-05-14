import PhotosUI
import SwiftUI
import UIKit

struct ListingImagePickerView: View {
    let previews: [UIImage]
    let onAdd: ([Data]) -> Void
    let onRemove: (Int) -> Void

    @State private var selectedItems: [PhotosPickerItem] = []

    private let maxImages = 5
    private let itemSize: CGFloat = 132

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Image(systemName: "photo")

                Text("Photos")
                    .font(.headline)

                Spacer()

                Text("\(previews.count)/\(maxImages)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(previews.enumerated()), id: \.offset) { index, image in
                        ZStack(alignment: .topTrailing) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: itemSize, height: itemSize)
                                .clipped()
                                .background(Color(.secondarySystemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

                            Button {
                                onRemove(index)
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title3)
                                    .foregroundStyle(.white, .black.opacity(0.35))
                                    .shadow(radius: 6)
                            }
                            .padding(8)
                        }
                    }

                    PhotosPicker(
                        selection: $selectedItems,
                        maxSelectionCount: max(0, maxImages - previews.count),
                        matching: .images
                    ) {
                        VStack(spacing: 10) {
                            Image(systemName: "plus")
                                .font(.title2.weight(.semibold))
                                .foregroundColor(.accentPrimary)
                                .padding(.top, 16)

                            Text("Add Photo")
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.primary)
                        }
                        .frame(width: itemSize, height: itemSize)
                        .background(Color(.secondarySystemBackground))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .strokeBorder(
                                    Color.accentPrimary.opacity(0.15), style: StrokeStyle(lineWidth: 1, dash: [6])
                                )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                    .disabled(previews.count >= maxImages)
                    .opacity(previews.count >= maxImages ? 0.4 : 1)
                }
                .padding(.bottom, 2)
            }
            .onChange(of: selectedItems) { _, newItems in
                guard !newItems.isEmpty else { return }
                Task {
                    var dataItems: [Data] = []
                    for item in newItems {
                        if let data = try? await item.loadTransferable(type: Data.self) {
                            dataItems.append(data)
                        }
                    }
                    onAdd(dataItems)
                    selectedItems = []
                }
            }

            Text("Upload up to 5 photos. The first image will appear as the cover.")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

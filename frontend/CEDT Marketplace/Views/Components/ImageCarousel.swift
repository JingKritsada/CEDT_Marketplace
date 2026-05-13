import SwiftUI

struct ImageCarousel: View {
    let imageUrls: [String]

    var body: some View {
        if imageUrls.isEmpty {
            ZStack {
                Color.gray.opacity(0.2)
                VStack(spacing: 6) {
                    Image(systemName: "photo")
                        .font(.system(size: 36))
                        .foregroundColor(.gray)
                    Text("No Images Available")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            .frame(height: 220)
        } else {
            TabView {
                ForEach(imageUrls, id: \.self) { url in
                    if let validUrl = URL(string: url) {
                        AsyncImage(url: validUrl) { phase in
                            switch phase {
                            case let .success(image):
                                image
                                    .resizable()
                                    .scaledToFill()
                            case .failure:
                                Color.gray.opacity(0.2)
                            case .empty:
                                ProgressView()
                            @unknown default:
                                Color.gray.opacity(0.2)
                            }
                        }
                        .frame(height: 220)
                        .clipped()
                    } else {
                        Color.gray.opacity(0.2)
                            .frame(height: 220)
                    }
                }
            }
            .tabViewStyle(.page)
            .frame(height: 220)
        }
    }
}

#Preview {
    ImageCarousel(imageUrls: [
        "https://picsum.photos/400/300",
        "https://picsum.photos/401/300",
    ])
}

import SwiftUI

struct ImageCarousel: View {
    let imageUrls: [String]

    var body: some View {
        if imageUrls.isEmpty {
            ZStack {
                Color.gray.opacity(0.2)

                VStack(spacing: 12) {
                    Image(systemName: "photo")
                        .font(.system(size: 36))
                        .foregroundColor(.gray)

                    Text("No Images Available")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            .frame(height: 360)
        } else {
            TabView {
                ForEach(imageUrls, id: \.self) { url in
                    if let validUrl = URL(string: url) {
                        AsyncImage(url: validUrl) { phase in
                            switch phase {
                            case .empty:
                                ZStack {
                                    Color.gray.opacity(0.2)

                                    ProgressView()
                                        .progressViewStyle(.circular)
                                        .tint(.gray)
                                        .scaleEffect(1.5)
                                }

                            case .failure:
                                ZStack {
                                    Color.gray.opacity(0.2)

                                    VStack(spacing: 12) {
                                        Image(systemName: "link")
                                            .padding(.top, 18)
                                            .font(.system(size: 36))
                                            .foregroundColor(.gray)
                                        Text("Invalid URL")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                }

                            case let .success(image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)

                            @unknown default:
                                Color.gray.opacity(0.1)
                            }
                        }
                        .clipped()
                    } else {
                        Color.gray.opacity(0.2)
                    }
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .automatic))
            .frame(height: 360)
        }
    }
}

#Preview {
    ImageCarousel(imageUrls: [
        "https://picsum.photos/400/300",
        "https://picsum.photos/401/300"
    ])
}

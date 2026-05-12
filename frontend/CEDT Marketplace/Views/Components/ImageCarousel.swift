import SwiftUI

struct ImageCarousel: View {
    let imageUrls: [String]

    var body: some View {
        TabView {
            ForEach(imageUrls, id: \.self) { url in
                AsyncImage(url: URL(string: url)) { phase in
                    switch phase {
                    case .success(let image):
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
            }
        }
        .tabViewStyle(.page)
        .frame(height: 220)
    }
}

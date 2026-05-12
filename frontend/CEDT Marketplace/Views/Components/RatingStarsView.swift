import SwiftUI

struct RatingStarsView: View {
    let rating: Double

    var body: some View {
        HStack(spacing: 2) {
            ForEach(1 ... 5, id: \.self) { index in
                Image(systemName: index <= Int(round(rating)) ? "star.fill" : "star")
                    .foregroundColor(.yellow)
            }
        }
    }
}

#Preview {
    RatingStarsView(rating: 4.5)
        .padding()
        .previewLayout(.sizeThatFits)
}

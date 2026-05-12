import SwiftUI

struct OnboardingView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                // Gear and Icon
                ZStack {
                    // Background Glow Shadow
                    Circle()
                        .fill(Color.pink.opacity(0.2))
                        .frame(width: 300, height: 300)
                        .blur(radius: 50)

                    // 2 Gears
                    Image(systemName: "gearshape.2.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 180, height: 180)
                        .foregroundColor(Color(.systemGray2))
                        .padding(40)
                        .background(
                            RoundedRectangle(cornerRadius: 50)
                                .fill(Color(.white))
                                .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
                        )

                    // Small icon
                    floatingIcon(name: "cpu", color: .pink, x: 130, y: -60)
                    floatingIcon(name: "wrench.and.screwdriver.fill", color: .blue, x: -130, y: 60)
                }

                Spacer()

                // Text Section
                VStack(spacing: 12) {
                    Text("INNOVATION EXCHANGE")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.pink)
                        .kerning(1.2)

                    Text("**CEDT** Marketplace")
                        .font(.system(size: 34, weight: .black))
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)

                    Text("Pass on your electronics and robotics gear. \nBuilt for students, by students.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }

                Spacer()

                // Buttons
                VStack(spacing: 12) {
                    NavigationLink(destination: LoginView()) {
                        Text("Login")
                            .font(.title3).bold()
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.accentPrimary)
                    .cornerRadius(18)

                    NavigationLink(destination: RegisterView()) {
                        Text("Register")
                            .font(.title3)
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                    }
                    .buttonStyle(.bordered)
                    .cornerRadius(18)
                }

                // Footer
                HStack {
                    Circle().fill(.red).frame(width: 6, height: 6)
                    Text("Chulalongkorn University Engineering")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .padding(.top, 10)
            }
            .padding(.horizontal, 24)
        }
    }

    func floatingIcon(name: String, color _: Color, x: CGFloat, y: CGFloat) -> some View {
        Image(systemName: name)
            .padding(10)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(radius: 5)
            .offset(x: x, y: y)
    }
}

#Preview {
    OnboardingView()
}

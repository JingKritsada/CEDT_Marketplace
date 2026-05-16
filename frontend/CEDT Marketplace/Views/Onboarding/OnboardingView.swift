import SwiftUI

struct OnboardingView: View {
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    private var illustrationSize: CGFloat {
        verticalSizeClass == .compact ? 120 : 180
    }

    private var glowSize: CGFloat {
        verticalSizeClass == .compact ? 200 : 300
    }

    private var floatOffset: CGFloat {
        verticalSizeClass == .compact ? 85 : 130
    }

    private var floatYOffset: CGFloat {
        verticalSizeClass == .compact ? 40 : 60
    }

    var body: some View {
        NavigationStack {
            ScrollView(.vertical) {
                VStack(spacing: verticalSizeClass == .compact ? 16 : 32) {
                    Spacer(minLength: verticalSizeClass == .compact ? 8 : 24)

                    // Gear and Icon
                    ZStack {
                        Circle()
                            .fill(Color.pink.opacity(0.5))
                            .frame(width: glowSize, height: glowSize)
                            .blur(radius: 100)

                        Image(systemName: "gearshape.2.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: illustrationSize, height: illustrationSize)
                            .foregroundColor(Color(.systemGray2))
                            .padding(illustrationSize * 0.22)
                            .background(
                                RoundedRectangle(cornerRadius: 50)
                                    .fill(Color(.systemBackground))
                                    .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
                            )

                        floatingIcon(name: "cpu", x: floatOffset, y: -floatYOffset)
                        floatingIcon(name: "wrench.and.screwdriver.fill", x: -floatOffset, y: floatYOffset)
                    }
                    .frame(height: glowSize)

                    Spacer(minLength: verticalSizeClass == .compact ? 4 : 16)

                    // Text Section
                    VStack(spacing: 12) {
                        Text("INNOVATION EXCHANGE")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.pink)
                            .kerning(1.2)

                        Text("**CEDT** Marketplace")
                            .font(.system(size: verticalSizeClass == .compact ? 26 : 34, weight: .black))
                            .multilineTextAlignment(.center)
                            .lineSpacing(2)

                        Text("Pass on your electronics and robotics gear. \nBuilt for students, by students.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }

                    Spacer(minLength: verticalSizeClass == .compact ? 4 : 16)

                    // Buttons
                    VStack(spacing: 12) {
                        NavigationLink(destination: LoginView()) {
                            Text("Login")
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.accentPrimary)
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                        .buttonStyle(.plain)

                        NavigationLink(destination: RegisterView()) {
                            Text("Register")
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.primary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color(.secondarySystemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                        .buttonStyle(.plain)

                        HStack {
                            Circle().fill(.red).frame(width: 6, height: 6)
                            Text("Chulalongkorn University Engineering")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 10)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
    }

    private func floatingIcon(name: String, x: CGFloat, y: CGFloat) -> some View {
        Image(systemName: name)
            .padding(10)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(radius: 5)
            .offset(x: x, y: y)
    }
}

#Preview {
    OnboardingView()
}

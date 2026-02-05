import SwiftUI

enum CalmTheme {
    static let backgroundTop = Color(red: 0.88, green: 0.93, blue: 0.97)
    static let backgroundBottom = Color(red: 0.98, green: 0.97, blue: 0.95)
    static let primaryText = Color(red: 0.13, green: 0.16, blue: 0.20)
    static let secondaryText = Color(red: 0.35, green: 0.39, blue: 0.43)
    static let primaryAction = Color(red: 0.28, green: 0.41, blue: 0.49)
    static let inputBackground = Color.white.opacity(0.58)
    static let cardStroke = Color.white.opacity(0.62)
    static let shadow = Color.black.opacity(0.10)

    static var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [backgroundTop, backgroundBottom],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

struct ScreenContainer<Content: View>: View {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            CalmTheme.backgroundGradient.ignoresSafeArea()

            Circle()
                .fill(Color.white.opacity(0.18))
                .blur(radius: 36)
                .frame(width: 340, height: 340)
                .offset(x: -130, y: -300)

            Circle()
                .fill(Color.white.opacity(0.12))
                .blur(radius: 44)
                .frame(width: 300, height: 300)
                .offset(x: 140, y: 280)

            VStack {
                content
                    .padding(.horizontal, 20)
                    .padding(.vertical, 18)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .semibold, design: .rounded))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(CalmTheme.primaryAction.opacity(configuration.isPressed ? 0.83 : 1))
            )
            .shadow(color: CalmTheme.shadow, radius: configuration.isPressed ? 2 : 8, y: configuration.isPressed ? 1 : 5)
    }
}

struct SecondaryOutlineButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .medium, design: .rounded))
            .foregroundStyle(CalmTheme.primaryText.opacity(configuration.isPressed ? 0.75 : 1))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.45))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(CalmTheme.cardStroke, lineWidth: 1)
                    )
            )
    }
}

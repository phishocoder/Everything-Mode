import SwiftUI

enum CalmTheme {
    static let primaryText = Color(red: 0.09, green: 0.11, blue: 0.16)
    static let secondaryText = Color(red: 0.19, green: 0.23, blue: 0.31)
    static let whiteSoft = Color.white.opacity(0.72)
    static let whiteStroke = Color.white.opacity(0.58)

    static var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [Color(red: 0.83, green: 0.90, blue: 0.99), Color(red: 0.78, green: 0.84, blue: 0.98)],
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
            CalmTheme.backgroundGradient
                .ignoresSafeArea()

            Circle()
                .fill(Color.white.opacity(0.2))
                .blur(radius: 48)
                .frame(width: 300, height: 300)
                .offset(x: -120, y: -260)

            Circle()
                .fill(Color.white.opacity(0.16))
                .blur(radius: 54)
                .frame(width: 260, height: 260)
                .offset(x: 130, y: 280)

            VStack {
                content
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 14)
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
                    .fill(Color.black.opacity(configuration.isPressed ? 0.32 : 0.24))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
    }
}

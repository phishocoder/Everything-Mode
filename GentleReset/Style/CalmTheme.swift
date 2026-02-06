import SwiftUI

enum CalmTheme {
    static let primaryText = Color(red: 0.09, green: 0.11, blue: 0.16)
    static let secondaryText = Color(red: 0.19, green: 0.23, blue: 0.31)
    static let whiteSoft = Color.white.opacity(0.72)
    static let whiteStroke = Color.white.opacity(0.58)

    static func gradient(for mood: EmotionalState?) -> LinearGradient {
        let colors: [Color]

        switch mood {
        case .racing:
            colors = [Color(red: 0.54, green: 0.75, blue: 1.00), Color(red: 0.35, green: 0.53, blue: 0.92)]
        case .heavy:
            colors = [Color(red: 0.86, green: 0.66, blue: 0.54), Color(red: 0.60, green: 0.46, blue: 0.63)]
        case .numb:
            colors = [Color(red: 0.71, green: 0.82, blue: 0.82), Color(red: 0.52, green: 0.64, blue: 0.72)]
        case .scattered:
            colors = [Color(red: 0.69, green: 0.89, blue: 0.73), Color(red: 0.42, green: 0.69, blue: 0.82)]
        case .none:
            colors = [Color(red: 0.84, green: 0.89, blue: 0.99), Color(red: 0.78, green: 0.77, blue: 0.97)]
        }

        return LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

struct ScreenContainer<Content: View>: View {
    let mood: EmotionalState?
    private let content: Content

    init(mood: EmotionalState?, @ViewBuilder content: () -> Content) {
        self.mood = mood
        self.content = content()
    }

    var body: some View {
        ZStack {
            CalmTheme.gradient(for: mood)
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

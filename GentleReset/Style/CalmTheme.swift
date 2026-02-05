import SwiftUI

enum CalmTheme {
    static let background = Color(red: 0.95, green: 0.95, blue: 0.93)
    static let card = Color(red: 0.98, green: 0.98, blue: 0.97)
    static let primaryText = Color(red: 0.16, green: 0.17, blue: 0.19)
    static let secondaryText = Color(red: 0.36, green: 0.37, blue: 0.40)
    static let primaryAction = Color(red: 0.34, green: 0.40, blue: 0.42)
    static let border = Color(red: 0.83, green: 0.84, blue: 0.82)
}

struct ScreenContainer<Content: View>: View {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            CalmTheme.background.ignoresSafeArea()

            VStack {
                content
                    .padding(22)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .semibold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(CalmTheme.primaryAction.opacity(configuration.isPressed ? 0.84 : 1))
            .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

struct SecondaryOutlineButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .medium))
            .foregroundStyle(CalmTheme.primaryText.opacity(configuration.isPressed ? 0.7 : 1))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(CalmTheme.border, lineWidth: 1)
                    .background(CalmTheme.card.opacity(0.7))
            )
            .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

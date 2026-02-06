import UIKit

enum LightHaptics {
    private static let light = UIImpactFeedbackGenerator(style: .light)
    private static let medium = UIImpactFeedbackGenerator(style: .medium)
    private static let success = UINotificationFeedbackGenerator()

    static func tap() {
        light.impactOccurred(intensity: 0.8)
    }

    static func breath(_ phase: BreathPhase) {
        switch phase {
        case .inhale:
            light.impactOccurred(intensity: 0.55)
        case .exhale:
            medium.impactOccurred(intensity: 0.45)
        }
    }

    static func complete() {
        success.notificationOccurred(.success)
    }
}

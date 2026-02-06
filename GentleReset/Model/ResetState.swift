import Foundation

enum ResetStep: Int {
    case welcome
    case mood
    case breathe
    case release
    case complete
}

enum EmotionalState: String, CaseIterable, Identifiable, Codable {
    case racing
    case heavy
    case numb
    case scattered

    var id: String { rawValue }

    var title: String {
        switch self {
        case .racing:
            return "Racing"
        case .heavy:
            return "Heavy"
        case .numb:
            return "Numb"
        case .scattered:
            return "Scattered"
        }
    }

    var subtitle: String {
        switch self {
        case .racing:
            return "Thoughts are sprinting and won't slow down."
        case .heavy:
            return "Everything feels weighty, even small things."
        case .numb:
            return "You feel checked out or shut down."
        case .scattered:
            return "Too many tabs open in your head."
        }
    }
}

enum ReliefChoice: String, CaseIterable, Identifiable, Codable {
    case twoMinutes
    case park
    case release

    var id: String { rawValue }

    var title: String {
        switch self {
        case .twoMinutes:
            return "2 min now"
        case .park:
            return "Park for later"
        case .release:
            return "Not today"
        }
    }
}

enum BreathPhase {
    case inhale
    case exhale

    var next: BreathPhase {
        switch self {
        case .inhale:
            return .exhale
        case .exhale:
            return .inhale
        }
    }

    var duration: TimeInterval {
        switch self {
        case .inhale:
            return 4
        case .exhale:
            return 5
        }
    }

    var label: String {
        switch self {
        case .inhale:
            return "Breathe in"
        case .exhale:
            return "Breathe out"
        }
    }
}

struct ResetDraft: Codable {
    var mood: EmotionalState?
    var releaseLine: String
    var reliefChoice: ReliefChoice?
}

struct LastResetSummary: Codable {
    var timestamp: Date
    var mood: EmotionalState
    var reliefChoice: ReliefChoice
}

struct ResetStorage {
    private enum Keys {
        static let draft = "everything_mode.v2_draft"
        static let summary = "everything_mode.v2_summary"
    }

    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func loadDraft() -> ResetDraft? {
        guard let data = defaults.data(forKey: Keys.draft) else { return nil }
        return try? decoder.decode(ResetDraft.self, from: data)
    }

    func saveDraft(_ draft: ResetDraft) {
        guard let data = try? encoder.encode(draft) else { return }
        defaults.set(data, forKey: Keys.draft)
    }

    func clearDraft() {
        defaults.removeObject(forKey: Keys.draft)
    }

    func loadSummary() -> LastResetSummary? {
        guard let data = defaults.data(forKey: Keys.summary) else { return nil }
        return try? decoder.decode(LastResetSummary.self, from: data)
    }

    func saveSummary(_ summary: LastResetSummary) {
        guard let data = try? encoder.encode(summary) else { return }
        defaults.set(data, forKey: Keys.summary)
    }
}

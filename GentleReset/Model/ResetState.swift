import Foundation

enum ResetStep: Int {
    case welcome
    case breathe
    case translatePrompt
    case translateInput
    case translateResult
    case exit
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
    var rawInput: String
}

struct AdminSnapshot: Codable {
    var createdAt: Date
    var pressureItems: [String]
    var emotionalWeight: String
    var safeToIgnoreToday: String
    var nextMove: String
}

struct ResetStorage {
    private enum Keys {
        static let draft = "everything_mode.v4_draft"
        static let latestSnapshot = "everything_mode.v4_latest_snapshot"
        static let reminderEnabled = "everything_mode.v4_reminder_enabled"
        static let translationDate = "everything_mode.v4_translation_date"
        static let paidUnlocked = "everything_mode.v4_paid_unlocked"
        static let apiKey = "everything_mode.v4_api_key"
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

    func loadLatestSnapshot() -> AdminSnapshot? {
        guard let data = defaults.data(forKey: Keys.latestSnapshot) else { return nil }
        return try? decoder.decode(AdminSnapshot.self, from: data)
    }

    func saveLatestSnapshot(_ snapshot: AdminSnapshot) {
        guard let data = try? encoder.encode(snapshot) else { return }
        defaults.set(data, forKey: Keys.latestSnapshot)
    }

    func loadReminderEnabled() -> Bool {
        defaults.bool(forKey: Keys.reminderEnabled)
    }

    func saveReminderEnabled(_ enabled: Bool) {
        defaults.set(enabled, forKey: Keys.reminderEnabled)
    }

    func loadLastTranslationDate() -> Date? {
        defaults.object(forKey: Keys.translationDate) as? Date
    }

    func saveLastTranslationDate(_ date: Date) {
        defaults.set(date, forKey: Keys.translationDate)
    }

    func loadPaidUnlocked() -> Bool {
        defaults.bool(forKey: Keys.paidUnlocked)
    }

    func savePaidUnlocked(_ unlocked: Bool) {
        defaults.set(unlocked, forKey: Keys.paidUnlocked)
    }

    func loadAPIKey() -> String {
        defaults.string(forKey: Keys.apiKey) ?? ""
    }

    func saveAPIKey(_ key: String) {
        defaults.set(key.trimmingCharacters(in: .whitespacesAndNewlines), forKey: Keys.apiKey)
    }
}

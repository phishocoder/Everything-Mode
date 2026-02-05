import Foundation

enum ResetStep: Int, CaseIterable {
    case arrive
    case dump
    case categorize
    case chooseAction
    case chooseClosing
    case complete

    var title: String {
        switch self {
        case .arrive:
            return "Arrive"
        case .dump:
            return "Unload"
        case .categorize:
            return "Sort gently"
        case .chooseAction:
            return "Pick one"
        case .chooseClosing:
            return "Close this"
        case .complete:
            return "Done"
        }
    }
}

enum WeightCategory: String, CaseIterable, Identifiable, Codable, Hashable {
    case practical
    case emotional
    case people
    case body
    case admin

    var id: String { rawValue }

    var title: String {
        switch self {
        case .practical:
            return "Practical"
        case .emotional:
            return "Emotional"
        case .people:
            return "People"
        case .body:
            return "Body"
        case .admin:
            return "Admin"
        }
    }

    var hint: String {
        switch self {
        case .practical:
            return "chores, errands, loose ends"
        case .emotional:
            return "fear, shame, grief, pressure"
        case .people:
            return "family, friends, work dynamics"
        case .body:
            return "sleep, hunger, tension, health"
        case .admin:
            return "forms, inbox, bills, systems"
        }
    }
}

enum ClosingChoice: String, CaseIterable, Identifiable, Codable {
    case briefAction
    case parkIt
    case releaseIt

    var id: String { rawValue }

    var title: String {
        switch self {
        case .briefAction:
            return "Do 2 minutes now"
        case .parkIt:
            return "Park it for later"
        case .releaseIt:
            return "Let it be for now"
        }
    }

    var detail: String {
        switch self {
        case .briefAction:
            return "A tiny start counts. Stop after two minutes."
        case .parkIt:
            return "Put it on your calendar and get your mind back."
        case .releaseIt:
            return "Not everything needs your energy today."
        }
    }
}

struct ResetDraft: Codable {
    var brainDump: String
    var selectedCategories: [WeightCategory]
    var chosenAction: String
    var closingChoice: ClosingChoice?
}

struct LastResetSummary: Codable {
    var timestamp: Date
    var action: String
    var closingChoice: ClosingChoice
}

struct ResetStorage {
    private enum Keys {
        static let draft = "everything_mode.reset_draft"
        static let summary = "everything_mode.last_summary"
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

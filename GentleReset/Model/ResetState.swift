import Foundation

enum ResetStep: Int {
    case welcome
    case brainDump
    case chooseAction
    case chooseMode
    case exit
}

enum GentleMode: String, CaseIterable, Identifiable {
    case doBriefly = "Do briefly"
    case clarify = "Clarify"
    case schedule = "Schedule"
    case ignore = "Ignore for now"

    var id: String { rawValue }

    var description: String {
        switch self {
        case .doBriefly:
            return "Give it two minutes only. Stop when the timer ends."
        case .clarify:
            return "Write one sentence to make the next step less fuzzy."
        case .schedule:
            return "Set a time for later so it can leave your head for now."
        case .ignore:
            return "Choose peace: this can wait without guilt today."
        }
    }
}

final class ResetState: ObservableObject {
    @Published var step: ResetStep = .welcome
    @Published var brainDump: String = "" {
        didSet {
            guard brainDump != oldValue else { return }
            UserDefaults.standard.set(brainDump, forKey: Self.brainDumpKey)
        }
    }
    @Published var pressureReducingAction: String = ""
    @Published var selectedMode: GentleMode?

    private static let brainDumpKey = "overwhelm.brainDumpDraft"

    init() {
        brainDump = UserDefaults.standard.string(forKey: Self.brainDumpKey) ?? ""
    }

    func next() {
        switch step {
        case .welcome:
            step = .brainDump
        case .brainDump:
            step = .chooseAction
        case .chooseAction:
            step = .chooseMode
        case .chooseMode:
            step = .exit
        case .exit:
            resetSession(keepDraft: false)
        }
    }

    func back() {
        switch step {
        case .welcome:
            break
        case .brainDump:
            step = .welcome
        case .chooseAction:
            step = .brainDump
        case .chooseMode:
            step = .chooseAction
        case .exit:
            step = .chooseMode
        }
    }

    func resetSession(keepDraft: Bool) {
        step = .welcome
        pressureReducingAction = ""
        selectedMode = nil
        if !keepDraft {
            brainDump = ""
            UserDefaults.standard.removeObject(forKey: Self.brainDumpKey)
        }
    }
}

import Foundation

@MainActor
final class EverythingModeViewModel: ObservableObject {
    @Published var step: ResetStep = .arrive
    @Published var brainDump: String = "" {
        didSet { persistDraft() }
    }
    @Published var selectedCategories: Set<WeightCategory> = [] {
        didSet { persistDraft() }
    }
    @Published var chosenAction: String = "" {
        didSet { persistDraft() }
    }
    @Published var closingChoice: ClosingChoice? {
        didSet { persistDraft() }
    }

    @Published private(set) var lastSummary: LastResetSummary?

    private let storage: ResetStorage

    init(storage: ResetStorage = ResetStorage()) {
        self.storage = storage
        restoreState()
    }

    var stepCount: Int { ResetStep.allCases.count }

    var canMoveForward: Bool {
        switch step {
        case .arrive, .dump, .complete:
            return true
        case .categorize:
            return !selectedCategories.isEmpty
        case .chooseAction:
            return !chosenAction.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .chooseClosing:
            return closingChoice != nil
        }
    }

    var primaryButtonTitle: String {
        switch step {
        case .arrive:
            return "Start reset"
        case .dump:
            return "Continue"
        case .categorize:
            return "Continue"
        case .chooseAction:
            return "Continue"
        case .chooseClosing:
            return "Finish reset"
        case .complete:
            return "Reset again"
        }
    }

    var progressText: String {
        "Step \(step.rawValue + 1) of \(stepCount)"
    }

    var selectedCategoriesText: String {
        if selectedCategories.isEmpty {
            return "Uncategorized"
        }

        return selectedCategories
            .map(\ .title)
            .sorted()
            .joined(separator: " • ")
    }

    func toggleCategory(_ category: WeightCategory) {
        if selectedCategories.contains(category) {
            selectedCategories.remove(category)
            return
        }

        // Keep this constrained to reduce decision fatigue.
        if selectedCategories.count < 3 {
            selectedCategories.insert(category)
        }
    }

    func next() {
        switch step {
        case .arrive:
            step = .dump
        case .dump:
            step = .categorize
        case .categorize:
            step = .chooseAction
        case .chooseAction:
            step = .chooseClosing
        case .chooseClosing:
            finalizeReset()
            step = .complete
        case .complete:
            startOver(clearSummary: false)
        }
    }

    func back() {
        switch step {
        case .arrive:
            break
        case .dump:
            step = .arrive
        case .categorize:
            step = .dump
        case .chooseAction:
            step = .categorize
        case .chooseClosing:
            step = .chooseAction
        case .complete:
            step = .chooseClosing
        }
    }

    private func finalizeReset() {
        guard let closingChoice else { return }

        let summary = LastResetSummary(
            timestamp: Date(),
            action: chosenAction.trimmingCharacters(in: .whitespacesAndNewlines),
            closingChoice: closingChoice
        )

        lastSummary = summary
        storage.saveSummary(summary)
        storage.clearDraft()
    }

    private func startOver(clearSummary: Bool) {
        step = .arrive
        brainDump = ""
        selectedCategories = []
        chosenAction = ""
        closingChoice = nil
        storage.clearDraft()
        if clearSummary {
            lastSummary = nil
        }
    }

    private func persistDraft() {
        let draft = ResetDraft(
            brainDump: brainDump,
            selectedCategories: Array(selectedCategories),
            chosenAction: chosenAction,
            closingChoice: closingChoice
        )
        storage.saveDraft(draft)
    }

    private func restoreState() {
        if let draft = storage.loadDraft() {
            brainDump = draft.brainDump
            selectedCategories = Set(draft.selectedCategories)
            chosenAction = draft.chosenAction
            closingChoice = draft.closingChoice
        }

        lastSummary = storage.loadSummary()
    }
}

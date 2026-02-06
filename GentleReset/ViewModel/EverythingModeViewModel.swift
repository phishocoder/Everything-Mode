import Foundation
import SwiftUI

@MainActor
final class EverythingModeViewModel: ObservableObject {
    @Published var step: ResetStep = .mood
    @Published var selectedMood: EmotionalState? {
        didSet { persistDraft() }
    }
    @Published var releaseLine: String = "" {
        didSet { persistDraft() }
    }
    @Published var reliefChoice: ReliefChoice? {
        didSet { persistDraft() }
    }

    @Published var breathPhase: BreathPhase = .inhale
    @Published var breathScale: CGFloat = 0.88
    @Published var completedBreathCycles = 0
    @Published private(set) var lastSummary: LastResetSummary?

    private var breathingTask: Task<Void, Never>?
    private let storage: ResetStorage

    init(storage: ResetStorage = ResetStorage()) {
        self.storage = storage
        restoreState()
    }

    var canStartReset: Bool {
        selectedMood != nil
    }

    var canFinishReset: Bool {
        reliefChoice != nil
    }

    var canContinueFromBreathing: Bool {
        completedBreathCycles >= 1
    }

    var shortSummaryText: String {
        guard let lastSummary else {
            return "No streaks. No score."
        }

        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return "Last reset \(formatter.localizedString(for: lastSummary.timestamp, relativeTo: Date()))"
    }

    func startReset() {
        guard canStartReset else { return }
        LightHaptics.tap()
        step = .breathe
        startBreathingLoop()
    }

    func continueFromBreathing() {
        stopBreathingLoop()
        LightHaptics.tap()
        step = .release
    }

    func finishReset() {
        guard let mood = selectedMood, let reliefChoice else { return }

        let summary = LastResetSummary(timestamp: Date(), mood: mood, reliefChoice: reliefChoice)
        storage.saveSummary(summary)
        lastSummary = summary
        storage.clearDraft()
        LightHaptics.complete()
        step = .complete
    }

    func resetAgain() {
        step = .mood
        releaseLine = ""
        reliefChoice = nil
        completedBreathCycles = 0
        breathScale = 0.88
        breathPhase = .inhale
        storage.clearDraft()
        LightHaptics.tap()
    }

    private func startBreathingLoop() {
        stopBreathingLoop()
        completedBreathCycles = 0
        runBreathPhase(.inhale)
    }

    private func runBreathPhase(_ phase: BreathPhase) {
        guard step == .breathe else { return }

        breathPhase = phase
        LightHaptics.breath(phase)

        withAnimation(.easeInOut(duration: phase.duration)) {
            breathScale = (phase == .inhale) ? 1.16 : 0.88
        }

        breathingTask = Task { [weak self] in
            guard let self else { return }
            try? await Task.sleep(nanoseconds: UInt64(phase.duration * 1_000_000_000))
            guard !Task.isCancelled else { return }

            if phase == .exhale {
                completedBreathCycles += 1
            }

            runBreathPhase(phase.next)
        }
    }

    private func stopBreathingLoop() {
        breathingTask?.cancel()
        breathingTask = nil
    }

    private func persistDraft() {
        let draft = ResetDraft(mood: selectedMood, releaseLine: releaseLine, reliefChoice: reliefChoice)
        storage.saveDraft(draft)
    }

    private func restoreState() {
        if let draft = storage.loadDraft() {
            selectedMood = draft.mood
            releaseLine = draft.releaseLine
            reliefChoice = draft.reliefChoice
        }

        lastSummary = storage.loadSummary()
    }
}

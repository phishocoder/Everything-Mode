import Foundation
import SwiftUI

@MainActor
final class EverythingModeViewModel: ObservableObject {
    @Published var step: ResetStep = .welcome
    @Published var selectedMood: EmotionalState? {
        didSet { persistDraft() }
    }

    @Published var breathPhase: BreathPhase = .inhale
    @Published var breathScale: CGFloat = 0.88
    @Published var elapsedSeconds: Int = 0
    @Published private(set) var isReminderEnabled = false
    @Published private(set) var lastSummary: LastResetSummary?

    private var breathingTask: Task<Void, Never>?
    private let storage: ResetStorage
    private let reminderService: ReminderService
    private let regulationDuration: TimeInterval

    init(
        storage: ResetStorage = ResetStorage(),
        reminderService: ReminderService = .shared,
        regulationDuration: TimeInterval = 60
    ) {
        self.storage = storage
        self.reminderService = reminderService
        self.regulationDuration = regulationDuration
        restoreState()
    }

    var shortSummaryText: String {
        guard let lastSummary else {
            return "No streaks. No score."
        }

        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return "Last reset \(formatter.localizedString(for: lastSummary.timestamp, relativeTo: Date()))"
    }

    var progress: Double {
        min(Double(elapsedSeconds) / regulationDuration, 1)
    }

    func beginFromWelcome() {
        LightHaptics.tap()
        step = .mood
    }

    func selectMoodAndStart(_ mood: EmotionalState) {
        selectedMood = mood
        LightHaptics.tap()
        step = .breathe
        startBreathingLoop()
    }

    func enableReminder() {
        Task {
            let enabled = await reminderService.enableDailyReminder()
            if enabled {
                isReminderEnabled = true
                storage.saveReminderEnabled(true)
                LightHaptics.tap()
            }
        }
    }

    func disableReminder() {
        reminderService.disableDailyReminder()
        isReminderEnabled = false
        storage.saveReminderEnabled(false)
    }

    func resetAgain() {
        step = .welcome
        completedResetCleanup()
        LightHaptics.tap()
    }

    private func startBreathingLoop() {
        stopBreathingLoop()
        elapsedSeconds = 0
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

            elapsedSeconds += Int(phase.duration)

            if Double(elapsedSeconds) >= regulationDuration {
                finishRegulation()
                return
            }

            runBreathPhase(phase.next)
        }
    }

    private func finishRegulation() {
        stopBreathingLoop()

        if let mood = selectedMood {
            let summary = LastResetSummary(timestamp: Date(), mood: mood)
            storage.saveSummary(summary)
            lastSummary = summary
        }

        storage.clearDraft()
        LightHaptics.complete()
        step = .complete
    }

    private func stopBreathingLoop() {
        breathingTask?.cancel()
        breathingTask = nil
    }

    private func completedResetCleanup() {
        stopBreathingLoop()
        selectedMood = nil
        elapsedSeconds = 0
        breathScale = 0.88
        breathPhase = .inhale
        storage.clearDraft()
    }

    private func persistDraft() {
        let draft = ResetDraft(mood: selectedMood)
        storage.saveDraft(draft)
    }

    private func restoreState() {
        if let draft = storage.loadDraft() {
            selectedMood = draft.mood
        }

        isReminderEnabled = storage.loadReminderEnabled()
        lastSummary = storage.loadSummary()
    }
}

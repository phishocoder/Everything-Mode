import Foundation
import SwiftUI

@MainActor
final class EverythingModeViewModel: ObservableObject {
    @Published var step: ResetStep = .welcome
    @Published var rawInput: String = "" {
        didSet { persistDraft() }
    }

    @Published var breathPhase: BreathPhase = .inhale
    @Published var breathScale: CGFloat = 0.88
    @Published var elapsedSeconds: Int = 0

    @Published private(set) var snapshot: AdminSnapshot?
    @Published private(set) var isTranslating = false
    @Published private(set) var translationError = ""
    @Published private(set) var isReminderEnabled = false

    private var breathingTask: Task<Void, Never>?
    private let storage: ResetStorage
    private let reminderService: ReminderService
    private let translator: AITranslationService
    private let regulationDuration: TimeInterval

    init(
        storage: ResetStorage = ResetStorage(),
        reminderService: ReminderService = .shared,
        translator: AITranslationService = AITranslationService(),
        regulationDuration: TimeInterval = 75
    ) {
        self.storage = storage
        self.reminderService = reminderService
        self.translator = translator
        self.regulationDuration = regulationDuration
        restoreState()
    }

    var progress: Double {
        min(Double(elapsedSeconds) / regulationDuration, 1)
    }

    var translationsRemainingText: String {
        canTranslateToday ? "Beta: 1 snapshot available" : "Beta snapshot used today"
    }

    var canTranslateToday: Bool {
        guard let lastDate = storage.loadLastTranslationDate() else { return true }
        return !Calendar.current.isDateInToday(lastDate)
    }

    func beginReset() {
        LightHaptics.tap()
        step = .breathe
        startBreathingLoop()
    }

    func skipRegulation() {
        stopBreathingLoop()
        elapsedSeconds = Int(regulationDuration)
        LightHaptics.tap()
        step = .translatePrompt
    }

    func skipTranslation() {
        LightHaptics.tap()
        step = .exit
    }

    func chooseTranslation() {
        guard canTranslateToday else {
            translationError = "Beta allows one Admin Snapshot per day."
            step = .translateResult
            return
        }

        translationError = ""
        LightHaptics.tap()
        step = .translateInput
    }

    func runTranslation() {
        guard !isTranslating else { return }

        let trimmed = rawInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            translationError = "Drop a quick messy note first."
            return
        }

        isTranslating = true
        translationError = ""

        Task {
            do {
                let built = try await translator.buildSnapshot(from: trimmed)
                snapshot = built
                storage.saveLatestSnapshot(built)
                storage.saveLastTranslationDate(Date())
                LightHaptics.complete()
                step = .translateResult
            } catch {
                translationError = error.localizedDescription
            }
            isTranslating = false
        }
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

    func startOver() {
        stopBreathingLoop()
        elapsedSeconds = 0
        breathScale = 0.88
        breathPhase = .inhale
        rawInput = ""
        translationError = ""
        step = .welcome
        storage.clearDraft()
        LightHaptics.tap()
    }

    func finishSession() {
        LightHaptics.tap()
        step = .exit
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
        LightHaptics.complete()
        step = .translatePrompt
    }

    private func stopBreathingLoop() {
        breathingTask?.cancel()
        breathingTask = nil
    }

    private func persistDraft() {
        storage.saveDraft(ResetDraft(rawInput: rawInput))
    }

    private func restoreState() {
        if let draft = storage.loadDraft() {
            rawInput = draft.rawInput
        }

        isReminderEnabled = storage.loadReminderEnabled()

        if let latest = storage.loadLatestSnapshot(), Calendar.current.isDateInToday(latest.createdAt) {
            snapshot = latest
        }
    }
}

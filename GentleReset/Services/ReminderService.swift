import Foundation
import UserNotifications

@MainActor
final class ReminderService {
    static let shared = ReminderService()

    private let center: UNUserNotificationCenter
    private let reminderID = "everything_mode.daily_pause"

    init(center: UNUserNotificationCenter = .current()) {
        self.center = center
    }

    func enableDailyReminder() async -> Bool {
        let settings = await center.notificationSettings()

        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            break
        case .notDetermined:
            let granted = (try? await center.requestAuthorization(options: [.alert, .sound])) ?? false
            guard granted else { return false }
        default:
            return false
        }

        center.removePendingNotificationRequests(withIdentifiers: [reminderID])

        let content = UNMutableNotificationContent()
        content.title = "Everything Mode"
        content.body = "Pause for 60 seconds?"
        content.sound = .default

        var components = DateComponents()
        components.hour = 13
        components.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: reminderID, content: content, trigger: trigger)

        do {
            try await center.add(request)
            return true
        } catch {
            return false
        }
    }

    func disableDailyReminder() {
        center.removePendingNotificationRequests(withIdentifiers: [reminderID])
    }
}

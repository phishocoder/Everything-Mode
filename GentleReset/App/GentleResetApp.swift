import SwiftUI

@main
struct GentleResetApp: App {
    @StateObject private var resetState = ResetState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(resetState)
        }
    }
}

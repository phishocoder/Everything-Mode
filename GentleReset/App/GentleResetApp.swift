import SwiftUI

@main
struct GentleResetApp: App {
    @StateObject private var viewModel = EverythingModeViewModel()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(viewModel)
                .preferredColorScheme(.light)
        }
    }
}

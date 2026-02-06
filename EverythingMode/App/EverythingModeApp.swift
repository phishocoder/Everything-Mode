import SwiftUI

@main
struct EverythingModeApp: App {
    @StateObject private var viewModel: EverythingModeViewModel

    init() {
        let isUITest = ProcessInfo.processInfo.arguments.contains("UITEST_FAST")
        _viewModel = StateObject(
            wrappedValue: EverythingModeViewModel(regulationDuration: isUITest ? 6 : 75)
        )
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(viewModel)
                .preferredColorScheme(.light)
        }
    }
}

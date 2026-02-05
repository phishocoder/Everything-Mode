# Everything Mode

Everything Mode is a private, local-first iOS app for moments when life feels like too much.

It is not a task manager. It is a short emotional reset:
1. unload what is loud
2. gently bucket it
3. pick one relief action
4. choose a stopping boundary
5. close with dignity

## Product Decisions (V1)
- iPhone-only, portrait-only, SwiftUI, iOS 17+
- No accounts, no sync, no analytics, no notifications
- No AI API calls; the app is intentionally offline-first
- Constrained choices (max 3 categories) reduce decision fatigue
- One primary action per step keeps cognitive load low

## Architecture
- `Model/ResetState.swift`: domain types + local storage (`UserDefaults` JSON)
- `ViewModel/EverythingModeViewModel.swift`: session state and step transitions
- `App/RootView.swift`: multi-step SwiftUI flow and copy
- `Style/CalmTheme.swift`: visual tokens and component styles
- `Style/Haptics.swift`: subtle tap feedback

## Local Persistence
The app stores:
- in-progress draft (brain dump, categories, chosen action, closing choice)
- latest reset summary for context on next launch

No network calls are required.

## Run
```bash
xcodegen generate
open GentleReset.xcodeproj
```
Then run the `GentleReset` scheme on iPhone Simulator or a physical iPhone.

## Testing
```bash
xcodebuild -project "GentleReset.xcodeproj" -scheme "GentleReset" -destination 'platform=iOS Simulator,name=iPhone 17' test
```

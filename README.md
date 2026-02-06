# Everything Mode

Everything Mode is a private iPhone app for one job:
shift your state when everything feels like too much.

It is not a planner or task system.

## V1 Flow (minimal, opinionated)
1. Pick current state (`Racing`, `Heavy`, `Numb`, `Scattered`)
2. Follow a 60-second breathing pulse (with haptics)
3. Optional one-line release + one relief choice
4. Exit

## Product Decisions
- Fewer screens, less text, one primary action per screen
- Emotional state shift first, decision second
- Color mood adapts to selected state for immediate tone change
- Local-only storage (`UserDefaults`) for draft + last summary
- No account, no analytics, no notifications, no network calls

## Architecture
- `Model/ResetState.swift`: domain types + local storage
- `ViewModel/EverythingModeViewModel.swift`: flow orchestration and breathing engine
- `App/RootView.swift`: UI and transitions
- `Style/CalmTheme.swift`: mood gradients and components
- `Style/Haptics.swift`: tap, breathing, completion haptics

## Run
```bash
xcodegen generate
open GentleReset.xcodeproj
```

## Test
```bash
xcodebuild -project "GentleReset.xcodeproj" -scheme "GentleReset" -destination 'platform=iOS Simulator,name=iPhone 17' test
```

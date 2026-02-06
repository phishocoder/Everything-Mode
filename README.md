# Everything Mode

Everything Mode is a private iPhone app for one job: interrupt overload fast and create a felt shift in about one minute.

It is intentionally not a planner, task manager, or habit app.

## V1 Flow (state-shift first)
1. Welcome with a clear 60-second expectation
2. Pick the current overload state (tap once)
3. Auto-start full-screen breathing regulation with haptics
4. Clean completion with optional daily reminder toggle

## Product Decisions
- Near-zero thinking at entry: no typing, no setup, no extra start confirmation
- Tap-to-regulate: mood choice immediately starts the reset sequence
- Regulation is bounded and automatic to prevent extra cognitive decisions
- Local-only storage (`UserDefaults`) for last reset summary and reminder preference
- Optional local daily reminder notification (`Pause for 60 seconds?`) with neutral tone
- No account, no analytics, no cloud, no streaks

## Architecture
- `/Users/philshobo/Desktop/Everything Mode/GentleReset/Model/ResetState.swift`: domain types + local storage
- `/Users/philshobo/Desktop/Everything Mode/GentleReset/ViewModel/EverythingModeViewModel.swift`: flow orchestration + regulation engine
- `/Users/philshobo/Desktop/Everything Mode/GentleReset/App/RootView.swift`: screens, transitions, and pacing
- `/Users/philshobo/Desktop/Everything Mode/GentleReset/Services/ReminderService.swift`: local notification scheduling
- `/Users/philshobo/Desktop/Everything Mode/GentleReset/Style/CalmTheme.swift`: gradients and visual style
- `/Users/philshobo/Desktop/Everything Mode/GentleReset/Style/Haptics.swift`: tap/breath/complete haptics

## Run
```bash
xcodegen generate
open GentleReset.xcodeproj
```

## Test
```bash
xcodebuild -project "GentleReset.xcodeproj" -scheme "GentleReset" -destination 'platform=iOS Simulator,name=iPhone 17' test
```

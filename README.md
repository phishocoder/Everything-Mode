# Everything Mode

Everything Mode is a private iPhone app that runs one loop:

1. Regulate overwhelm (60-90 seconds)
2. Translate chaos into one concrete admin artifact
3. Exit cleanly

It is not a planner, journal, or habit system.

## Core Loop
- `Welcome`: sets expectation and starts immediately
- `Regulate`: auto-paced breathing + subtle haptics, no typing
- `Translate`: optional AI-powered **Admin Snapshot** from one raw input
- `Exit`: neutral close with optional daily reminder toggle

## Admin Snapshot Output
The translation output is constrained to:
- `TITLE`: What's actually here
- `PRESSURE SOURCES`: 1-2 admin items + 1 emotional weight
- `WHAT CAN WAIT`: 1 thing safe to ignore today
- `NEXT MOVE`: 1 practical action

## Free vs Paid (V1)
- Free:
  - Unlimited regulation
  - 1 Admin Snapshot per day (beta)
- Paid (placeholder only):
  - History
  - Weekly summaries
  - Admin grouping

## AI Constraints
- AI is used only in translation.
- Regulation never calls AI.
- Translation uses low temperature and strict JSON prompting for specificity.

## Trigger
- Optional daily low-frequency local notification:
  - “Everything piling up?”

## Architecture
- `/Users/philshobo/Desktop/Everything Mode/EverythingMode/App/RootView.swift`: loop screens and transitions
- `/Users/philshobo/Desktop/Everything Mode/EverythingMode/ViewModel/EverythingModeViewModel.swift`: state machine, pacing, gating
- `/Users/philshobo/Desktop/Everything Mode/EverythingMode/Services/AITranslationService.swift`: OpenAI translation call + JSON parsing
- `/Users/philshobo/Desktop/Everything Mode/EverythingMode/Services/ReminderService.swift`: daily notification scheduling
- `/Users/philshobo/Desktop/Everything Mode/EverythingMode/Model/ResetState.swift`: domain models + local storage

## AI Access
No API key entry exists in-app.
For beta testing, translation reads `OPENAI_API_KEY` from the app process environment.

## Run
```bash
xcodegen generate
open "everything mode".xcodeproj
```

## Test
```bash
xcodebuild -project "everything mode".xcodeproj -scheme "everything mode" -destination 'platform=iOS Simulator,name=iPhone 17' test
```

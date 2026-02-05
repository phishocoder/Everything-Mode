import SwiftUI

struct RootView: View {
    @EnvironmentObject private var state: ResetState

    var body: some View {
        ScreenContainer {
            VStack(alignment: .leading, spacing: 20) {
                progressHeader
                card
                navigationRow
            }
        }
    }

    private var progressHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("A small reset")
                .font(.system(size: 28, weight: .semibold, design: .rounded))
                .foregroundStyle(CalmTheme.primaryText)

            Text(stepLabel)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(CalmTheme.secondaryText)
        }
        .padding(.top, 8)
    }

    private var card: some View {
        VStack(alignment: .leading, spacing: 16) {
            currentStepView
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(CalmTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(CalmTheme.border, lineWidth: 1)
        )
    }

    @ViewBuilder
    private var currentStepView: some View {
        switch state.step {
        case .welcome:
            WelcomeStep()
        case .brainDump:
            BrainDumpStep()
        case .chooseAction:
            ChooseActionStep()
        case .chooseMode:
            ChooseModeStep()
        case .exit:
            ExitStep()
        }
    }

    private var navigationRow: some View {
        HStack(spacing: 12) {
            if state.step != .welcome {
                Button("Back") {
                    state.back()
                }
                .buttonStyle(SecondaryOutlineButtonStyle())
            }

            Button(primaryButtonTitle) {
                state.next()
            }
            .buttonStyle(PrimaryButtonStyle())
            .accessibilityIdentifier(primaryButtonIdentifier)
            .disabled(isPrimaryDisabled)
            .opacity(isPrimaryDisabled ? 0.45 : 1)
        }
        .animation(.easeInOut(duration: 0.2), value: state.step)
    }

    private var primaryButtonTitle: String {
        switch state.step {
        case .welcome:
            return "Start"
        case .brainDump:
            return "Continue"
        case .chooseAction:
            return "Pick this"
        case .chooseMode:
            return "Finish reset"
        case .exit:
            return "Done"
        }
    }

    private var isPrimaryDisabled: Bool {
        switch state.step {
        case .chooseAction:
            return state.pressureReducingAction.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .chooseMode:
            return state.selectedMode == nil
        default:
            return false
        }
    }

    private var stepLabel: String {
        switch state.step {
        case .welcome:
            return "Step 1 of 5"
        case .brainDump:
            return "Step 2 of 5"
        case .chooseAction:
            return "Step 3 of 5"
        case .chooseMode:
            return "Step 4 of 5"
        case .exit:
            return "Step 5 of 5"
        }
    }

    private var primaryButtonIdentifier: String {
        switch state.step {
        case .welcome:
            return "startButton"
        case .brainDump:
            return "continueButton"
        case .chooseAction:
            return "pickThisButton"
        case .chooseMode:
            return "finishResetButton"
        case .exit:
            return "doneButton"
        }
    }
}

private struct WelcomeStep: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("If everything feels like too much, you are not broken.")
                .font(.system(size: 24, weight: .semibold, design: .rounded))
                .foregroundStyle(CalmTheme.primaryText)

            Text("This is a short reset. No fixing your whole life. Just one gentle next move.")
                .font(.system(size: 17))
                .foregroundStyle(CalmTheme.secondaryText)

            Text("About 4-5 minutes.")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(CalmTheme.secondaryText)
                .padding(.top, 4)
        }
    }
}

private struct BrainDumpStep: View {
    @EnvironmentObject private var state: ResetState

    private let limit = 300

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Put it down for a moment")
                .font(.system(size: 22, weight: .semibold, design: .rounded))
                .foregroundStyle(CalmTheme.primaryText)

            Text("Write anything on your mind. Fragments are enough.")
                .font(.system(size: 16))
                .foregroundStyle(CalmTheme.secondaryText)

            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(CalmTheme.border, lineWidth: 1)
                    .background(CalmTheme.background.opacity(0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                if state.brainDump.isEmpty {
                    Text("Examples: money, inbox, laundry, family text, that one form...")
                        .foregroundStyle(CalmTheme.secondaryText.opacity(0.7))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 14)
                }

                TextEditor(text: limitedBrainDump)
                    .scrollContentBackground(.hidden)
                    .padding(8)
                    .frame(minHeight: 150, maxHeight: 180)
            }

            HStack {
                Text("Nothing needs to be organized.")
                    .font(.system(size: 13))
                    .foregroundStyle(CalmTheme.secondaryText)
                Spacer()
                Text("\(state.brainDump.count)/\(limit)")
                    .font(.system(size: 13, weight: .medium, design: .monospaced))
                    .foregroundStyle(CalmTheme.secondaryText)
            }
        }
    }

    private var limitedBrainDump: Binding<String> {
        Binding(
            get: { state.brainDump },
            set: { newValue in
                state.brainDump = String(newValue.prefix(limit))
            }
        )
    }
}

private struct ChooseActionStep: View {
    @EnvironmentObject private var state: ResetState

    private let limit = 80

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Choose one pressure-reducing action")
                .font(.system(size: 22, weight: .semibold, design: .rounded))
                .foregroundStyle(CalmTheme.primaryText)

            Text("Not the most important thing. Just the thing that would make this moment lighter.")
                .font(.system(size: 16))
                .foregroundStyle(CalmTheme.secondaryText)

            TextField("Example: Reply with one line to Alex", text: limitedAction)
                .textInputAutocapitalization(.sentences)
                .accessibilityIdentifier("actionTextField")
                .padding(14)
                .background(CalmTheme.background.opacity(0.65))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(CalmTheme.border, lineWidth: 1)
                )

            Text("\(state.pressureReducingAction.count)/\(limit)")
                .font(.system(size: 13, weight: .medium, design: .monospaced))
                .foregroundStyle(CalmTheme.secondaryText)
        }
    }

    private var limitedAction: Binding<String> {
        Binding(
            get: { state.pressureReducingAction },
            set: { newValue in
                state.pressureReducingAction = String(newValue.prefix(limit))
            }
        )
    }
}

private struct ChooseModeStep: View {
    @EnvironmentObject private var state: ResetState

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("How do you want to handle it?")
                .font(.system(size: 22, weight: .semibold, design: .rounded))
                .foregroundStyle(CalmTheme.primaryText)

            Text("\"\(state.pressureReducingAction)\"")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(CalmTheme.secondaryText)

            VStack(spacing: 10) {
                ForEach(GentleMode.allCases) { mode in
                    Button {
                        state.selectedMode = mode
                    } label: {
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: state.selectedMode == mode ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(state.selectedMode == mode ? CalmTheme.primaryAction : CalmTheme.secondaryText)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(mode.rawValue)
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundStyle(CalmTheme.primaryText)
                                Text(mode.description)
                                    .font(.system(size: 14))
                                    .foregroundStyle(CalmTheme.secondaryText)
                            }
                            Spacer()
                        }
                        .padding(12)
                        .background(CalmTheme.background.opacity(0.6))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(state.selectedMode == mode ? CalmTheme.primaryAction : CalmTheme.border, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier(mode.accessibilityID)
                }
            }
        }
    }
}

private struct ExitStep: View {
    @EnvironmentObject private var state: ResetState

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("You did enough for now.")
                .font(.system(size: 24, weight: .semibold, design: .rounded))
                .foregroundStyle(CalmTheme.primaryText)

            Text("Your choice:")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(CalmTheme.secondaryText)

            Text("• \(state.pressureReducingAction)")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(CalmTheme.primaryText)

            if let mode = state.selectedMode {
                Text("• Mode: \(mode.rawValue)")
                    .font(.system(size: 16))
                    .foregroundStyle(CalmTheme.secondaryText)
            }

            Text("Close the app or continue your day. No streaks. No score. You can come back whenever it helps.")
                .font(.system(size: 16))
                .foregroundStyle(CalmTheme.secondaryText)
                .padding(.top, 4)
        }
    }
}

#Preview {
    RootView()
        .environmentObject(ResetState())
}

private extension GentleMode {
    var accessibilityID: String {
        switch self {
        case .doBriefly:
            return "modeDoBrieflyButton"
        case .clarify:
            return "modeClarifyButton"
        case .schedule:
            return "modeScheduleButton"
        case .ignore:
            return "modeIgnoreButton"
        }
    }
}

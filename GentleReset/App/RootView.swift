import SwiftUI

struct RootView: View {
    @EnvironmentObject private var viewModel: EverythingModeViewModel

    var body: some View {
        ScreenContainer(mood: viewModel.selectedMood) {
            VStack(spacing: 18) {
                titleBar

                Group {
                    switch viewModel.step {
                    case .welcome:
                        WelcomeStep()
                    case .mood:
                        MoodStep()
                    case .breathe:
                        BreatheStep()
                    case .release:
                        ReleaseStep()
                    case .complete:
                        CompleteStep()
                    }
                }
                .transition(.opacity.combined(with: .scale(scale: 0.98)))

                Spacer(minLength: 6)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.step)
    }

    private var titleBar: some View {
        HStack {
            Text("everything mode")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundStyle(CalmTheme.primaryText)
            Spacer()
            Text(viewModel.shortSummaryText)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(CalmTheme.secondaryText.opacity(0.9))
        }
    }
}

private struct WelcomeStep: View {
    @EnvironmentObject private var viewModel: EverythingModeViewModel

    var body: some View {
        VStack(spacing: 18) {
            Text("Everything feels like too much.")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundStyle(CalmTheme.primaryText)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("This is a short reset. About 60 seconds.")
                .font(.system(size: 17, weight: .medium, design: .rounded))
                .foregroundStyle(CalmTheme.secondaryText)
                .frame(maxWidth: .infinity, alignment: .leading)

            Button("Begin") {
                viewModel.beginFromWelcome()
            }
            .buttonStyle(PrimaryButtonStyle())
            .accessibilityIdentifier("beginResetButton")
        }
        .padding(18)
        .glassCard()
    }
}

private struct MoodStep: View {
    @EnvironmentObject private var viewModel: EverythingModeViewModel

    var body: some View {
        VStack(spacing: 16) {
            Text("What kind of overwhelm is this?")
                .font(.system(size: 28, weight: .semibold, design: .rounded))
                .foregroundStyle(CalmTheme.primaryText)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("Close enough is perfect. Pick one and we start.")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(CalmTheme.secondaryText)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 10) {
                ForEach(EmotionalState.allCases) { mood in
                    Button {
                        // No second confirmation button: tap -> regulation starts immediately.
                        viewModel.selectMoodAndStart(mood)
                    } label: {
                        VStack(alignment: .leading, spacing: 3) {
                            HStack {
                                Text(mood.title)
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                                    .foregroundStyle(CalmTheme.primaryText)
                                Spacer()
                                if viewModel.selectedMood == mood {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(CalmTheme.secondaryText)
                                }
                            }
                            Text(mood.subtitle)
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundStyle(CalmTheme.secondaryText)
                        }
                        .padding(14)
                        .background(CalmTheme.whiteSoft)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(CalmTheme.whiteStroke, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("state_\(mood.rawValue)")
                }
            }
        }
        .padding(18)
        .glassCard()
    }
}

private struct BreatheStep: View {
    @EnvironmentObject private var viewModel: EverythingModeViewModel

    var body: some View {
        VStack(spacing: 16) {
            Text(viewModel.breathPhase.label)
                .font(.system(size: 30, weight: .semibold, design: .rounded))
                .foregroundStyle(CalmTheme.primaryText)

            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.22))
                    .frame(width: 220, height: 220)

                Circle()
                    .fill(Color.white.opacity(0.56))
                    .frame(width: 180, height: 180)
                    .scaleEffect(viewModel.breathScale)
                    .blur(radius: 0.2)
            }
            .padding(.vertical, 8)

            Text("Stay with the circle")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(CalmTheme.secondaryText)

            if viewModel.canContinueFromBreathing {
                Button("Continue") {
                    viewModel.continueFromBreathing()
                }
                .buttonStyle(PrimaryButtonStyle())
                .accessibilityIdentifier("continueFromBreathButton")
            }
        }
        .padding(18)
        .glassCard()
    }
}

private struct ReleaseStep: View {
    @EnvironmentObject private var viewModel: EverythingModeViewModel

    var body: some View {
        VStack(spacing: 14) {
            Text("Put it down for a moment (optional)")
                .font(.system(size: 24, weight: .semibold, design: .rounded))
                .foregroundStyle(CalmTheme.primaryText)
                .frame(maxWidth: .infinity, alignment: .leading)

            TextEditor(text: $viewModel.releaseLine)
                .textInputAutocapitalization(.sentences)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(CalmTheme.primaryText)
                .frame(minHeight: 110)
                .padding(10)
                .background(CalmTheme.whiteSoft)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(CalmTheme.whiteStroke, lineWidth: 1)
                )
                .accessibilityIdentifier("releaseLineField")

            HStack(spacing: 8) {
                ForEach(ReliefChoice.allCases) { choice in
                    Button {
                        viewModel.reliefChoice = choice
                        LightHaptics.tap()
                    } label: {
                        Text(choice.title)
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundStyle(CalmTheme.primaryText)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(viewModel.reliefChoice == choice ? Color.white.opacity(0.82) : CalmTheme.whiteSoft)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(CalmTheme.whiteStroke, lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("choice_\(choice.rawValue)")
                }
            }

            Button("Seal reset") {
                viewModel.finishReset()
            }
            .buttonStyle(PrimaryButtonStyle())
            .accessibilityIdentifier("finishResetButton")
            .disabled(!viewModel.canFinishReset)
            .opacity(viewModel.canFinishReset ? 1 : 0.45)
        }
        .padding(18)
        .glassCard()
    }
}

private struct CompleteStep: View {
    @EnvironmentObject private var viewModel: EverythingModeViewModel

    var body: some View {
        VStack(spacing: 16) {
            Text("Done for now.")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(CalmTheme.primaryText)

            Text("Leave the app. That's the win.")
                .font(.system(size: 17, weight: .medium, design: .rounded))
                .foregroundStyle(CalmTheme.secondaryText)

            Button("One more reset") {
                viewModel.resetAgain()
            }
            .buttonStyle(PrimaryButtonStyle())
            .accessibilityIdentifier("resetAgainButton")
        }
        .padding(18)
        .glassCard()
    }
}

private extension View {
    func glassCard() -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.white.opacity(0.46), lineWidth: 1)
                    )
            )
            .shadow(color: Color.black.opacity(0.08), radius: 14, y: 9)
    }
}

#Preview {
    RootView()
        .environmentObject(EverythingModeViewModel())
}

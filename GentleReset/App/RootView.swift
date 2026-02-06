import SwiftUI

struct RootView: View {
    @EnvironmentObject private var viewModel: EverythingModeViewModel

    var body: some View {
        ScreenContainer(mood: viewModel.selectedMood) {
            VStack(spacing: 18) {
                if viewModel.step != .breathe {
                    titleBar
                }

                Group {
                    switch viewModel.step {
                    case .welcome:
                        WelcomeStep()
                    case .mood:
                        MoodStep()
                    case .breathe:
                        BreatheStep()
                    case .complete:
                        CompleteStep()
                    }
                }
                .transition(.opacity.combined(with: .scale(scale: 0.98)))

                if viewModel.step != .breathe {
                    Spacer(minLength: 6)
                }
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
                .font(.system(size: 31, weight: .bold, design: .rounded))
                .foregroundStyle(CalmTheme.primaryText)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("When overload hits, this gives your nervous system one calm minute. No fixing, no planning, just a clean pause.")
                .font(.system(size: 17, weight: .medium, design: .rounded))
                .foregroundStyle(CalmTheme.secondaryText)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("About 60 seconds")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(CalmTheme.secondaryText.opacity(0.9))
                .frame(maxWidth: .infinity, alignment: .leading)

            Button("Start reset") {
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
            Text("Pick what this feels like right now")
                .font(.system(size: 28, weight: .semibold, design: .rounded))
                .foregroundStyle(CalmTheme.primaryText)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("Any option works. Tap once and the reset begins.")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(CalmTheme.secondaryText)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 10) {
                ForEach(EmotionalState.allCases) { mood in
                    Button {
                        // Choice should feel approximate, not diagnostic.
                        viewModel.selectMoodAndStart(mood)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(mood.title)
                                .font(.system(size: 19, weight: .semibold, design: .rounded))
                                .foregroundStyle(CalmTheme.primaryText)
                            Text(mood.subtitle)
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundStyle(CalmTheme.secondaryText)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
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
        VStack(spacing: 24) {
            Spacer(minLength: 0)

            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.24), lineWidth: 18)
                    .frame(width: 272, height: 272)

                Circle()
                    .trim(from: 0, to: viewModel.progress)
                    .stroke(Color.white.opacity(0.9), style: StrokeStyle(lineWidth: 18, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .frame(width: 272, height: 272)
                    .animation(.linear(duration: 0.25), value: viewModel.progress)

                Circle()
                    .fill(Color.white.opacity(0.52))
                    .frame(width: 184, height: 184)
                    .scaleEffect(viewModel.breathScale)
                    .shadow(color: Color.white.opacity(0.2), radius: 24)
                    .blur(radius: 0.15)
            }

            Text(viewModel.breathPhase.label)
                .font(.system(size: 24, weight: .semibold, design: .rounded))
                .foregroundStyle(CalmTheme.primaryText)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityIdentifier("breathingScreen")
    }
}

private struct CompleteStep: View {
    @EnvironmentObject private var viewModel: EverythingModeViewModel

    var body: some View {
        VStack(spacing: 16) {
            Text("Reset complete.")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(CalmTheme.primaryText)

            Text("You can close the app now.")
                .font(.system(size: 17, weight: .medium, design: .rounded))
                .foregroundStyle(CalmTheme.secondaryText)

            Button(viewModel.isReminderEnabled ? "Daily reminder on" : "Enable daily 60-second reminder") {
                if viewModel.isReminderEnabled {
                    viewModel.disableReminder()
                } else {
                    viewModel.enableReminder()
                }
            }
            .buttonStyle(SecondaryButtonStyle())
            .accessibilityIdentifier("toggleReminderButton")

            Button("Run another reset") {
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

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .semibold, design: .rounded))
            .foregroundStyle(CalmTheme.primaryText)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.white.opacity(configuration.isPressed ? 0.54 : 0.68))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.white.opacity(0.5), lineWidth: 1)
            )
    }
}

#Preview {
    RootView()
        .environmentObject(EverythingModeViewModel())
}

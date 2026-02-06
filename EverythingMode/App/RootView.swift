import SwiftUI

struct RootView: View {
    @EnvironmentObject private var viewModel: EverythingModeViewModel

    var body: some View {
        ScreenContainer {
            VStack(spacing: 18) {
                if viewModel.step != .breathe {
                    titleBar
                }

                Group {
                    switch viewModel.step {
                    case .welcome:
                        WelcomeStep()
                    case .breathe:
                        BreatheStep()
                    case .translatePrompt:
                        TranslatePromptStep()
                    case .translateInput:
                        TranslateInputStep()
                    case .translateResult:
                        TranslateResultStep()
                    case .exit:
                        ExitStep()
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
            Text(viewModel.translationsRemainingText)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(CalmTheme.secondaryText.opacity(0.9))
        }
    }
}

private struct WelcomeStep: View {
    @EnvironmentObject private var viewModel: EverythingModeViewModel

    var body: some View {
        VStack(spacing: 18) {
            Text("Everything piling up?")
                .font(.system(size: 31, weight: .bold, design: .rounded))
                .foregroundStyle(CalmTheme.primaryText)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("This app does two things: calm the noise, then turn the mess into one usable admin snapshot.")
                .font(.system(size: 17, weight: .medium, design: .rounded))
                .foregroundStyle(CalmTheme.secondaryText)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("About 2 minutes")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(CalmTheme.secondaryText.opacity(0.9))
                .frame(maxWidth: .infinity, alignment: .leading)

            Button("Start 60-second reset") {
                viewModel.beginReset()
            }
            .buttonStyle(PrimaryButtonStyle())
            .accessibilityIdentifier("beginResetButton")
        }
        .padding(18)
        .glassCard()
    }
}

private struct BreatheStep: View {
    @EnvironmentObject private var viewModel: EverythingModeViewModel

    var body: some View {
        VStack(spacing: 26) {
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

            Button("Skip breathing") {
                viewModel.skipRegulation()
            }
            .buttonStyle(SecondaryButtonStyle())
            .padding(.horizontal, 24)
            .accessibilityIdentifier("skipBreathingButton")

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct TranslatePromptStep: View {
    @EnvironmentObject private var viewModel: EverythingModeViewModel

    var body: some View {
        VStack(spacing: 18) {
            Text("Want me to help sort what's weighing on you?")
                .font(.system(size: 29, weight: .bold, design: .rounded))
                .foregroundStyle(CalmTheme.primaryText)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("One raw note in. One clear admin snapshot out.")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(CalmTheme.secondaryText)
                .frame(maxWidth: .infinity, alignment: .leading)

            Button("Yes, sort it") {
                viewModel.chooseTranslation()
            }
            .buttonStyle(PrimaryButtonStyle())
            .accessibilityIdentifier("sortItButton")

            Button("Skip and exit") {
                viewModel.skipTranslation()
            }
            .buttonStyle(SecondaryButtonStyle())
            .accessibilityIdentifier("skipTranslationButton")
        }
        .padding(18)
        .glassCard()
    }
}

private struct TranslateInputStep: View {
    @EnvironmentObject private var viewModel: EverythingModeViewModel

    var body: some View {
        VStack(spacing: 12) {
            Text("Drop the messy version")
                .font(.system(size: 27, weight: .bold, design: .rounded))
                .foregroundStyle(CalmTheme.primaryText)
                .frame(maxWidth: .infinity, alignment: .leading)

            TextEditor(text: $viewModel.rawInput)
                .textInputAutocapitalization(.sentences)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(CalmTheme.primaryText)
                .frame(minHeight: 150)
                .padding(10)
                .background(CalmTheme.whiteSoft)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(CalmTheme.whiteStroke, lineWidth: 1)
                )
                .accessibilityIdentifier("rawInputField")

            if !viewModel.translationError.isEmpty {
                Text(viewModel.translationError)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(Color(red: 0.56, green: 0.18, blue: 0.16))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Button(viewModel.isTranslating ? "Building snapshot..." : "Build Admin Snapshot") {
                viewModel.runTranslation()
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(viewModel.isTranslating)
            .opacity(viewModel.isTranslating ? 0.6 : 1)
            .accessibilityIdentifier("buildSnapshotButton")
        }
        .padding(18)
        .glassCard()
    }
}

private struct TranslateResultStep: View {
    @EnvironmentObject private var viewModel: EverythingModeViewModel

    var body: some View {
        VStack(spacing: 14) {
            if let snapshot = viewModel.snapshot, viewModel.translationError.isEmpty {
                Text("What's actually here")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(CalmTheme.primaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)

                SnapshotSection(title: "PRESSURE SOURCES") {
                    VStack(alignment: .leading, spacing: 5) {
                        ForEach(snapshot.pressureItems, id: \.self) { item in
                            Text("- \(item)")
                        }
                        Text("- Emotional weight: \(snapshot.emotionalWeight)")
                    }
                }

                SnapshotSection(title: "WHAT CAN WAIT") {
                    Text(snapshot.safeToIgnoreToday)
                }

                SnapshotSection(title: "NEXT MOVE") {
                    Text(snapshot.nextMove)
                }

                Button("Done") {
                    viewModel.finishSession()
                }
                .buttonStyle(PrimaryButtonStyle())
                .accessibilityIdentifier("doneSnapshotButton")
            } else {
                Text("Admin Snapshot unavailable")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(CalmTheme.primaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(viewModel.translationError)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(CalmTheme.secondaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Admin Snapshot beta")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                    Text("- One snapshot per day")
                    Text("- Unlimited regulation")
                    Text("- More history coming later")
                }
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(CalmTheme.secondaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(CalmTheme.whiteSoft)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                Button("Close") {
                    viewModel.finishSession()
                }
                .buttonStyle(PrimaryButtonStyle())
            }
        }
        .padding(18)
        .glassCard()
    }
}

private struct SnapshotSection<Content: View>: View {
    let title: String
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(CalmTheme.secondaryText)
            content
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(CalmTheme.primaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(CalmTheme.whiteSoft)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

private struct ExitStep: View {
    @EnvironmentObject private var viewModel: EverythingModeViewModel

    var body: some View {
        VStack(spacing: 16) {
            Text("Done for now.")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(CalmTheme.primaryText)

            Text("You're clear enough for the next move.")
                .font(.system(size: 17, weight: .medium, design: .rounded))
                .foregroundStyle(CalmTheme.secondaryText)

            Button(viewModel.isReminderEnabled ? "Daily reminder on" : "Enable daily nudge") {
                if viewModel.isReminderEnabled {
                    viewModel.disableReminder()
                } else {
                    viewModel.enableReminder()
                }
            }
            .buttonStyle(SecondaryButtonStyle())
            .accessibilityIdentifier("toggleReminderButton")

            Button("New reset") {
                viewModel.startOver()
            }
            .buttonStyle(PrimaryButtonStyle())
            .accessibilityIdentifier("startOverButton")
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

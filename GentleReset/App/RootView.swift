import SwiftUI

struct RootView: View {
    @EnvironmentObject private var viewModel: EverythingModeViewModel

    var body: some View {
        ScreenContainer {
            VStack(alignment: .leading, spacing: 20) {
                header
                stepCard
                navigationRow
            }
        }
        .animation(.easeInOut(duration: 0.24), value: viewModel.step)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Everything Mode")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundStyle(CalmTheme.primaryText)

            Text(viewModel.progressText)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(CalmTheme.secondaryText)
        }
    }

    private var stepCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            switch viewModel.step {
            case .arrive:
                ArriveStep()
            case .dump:
                DumpStep()
            case .categorize:
                CategorizeStep()
            case .chooseAction:
                ChooseActionStep()
            case .chooseClosing:
                ChooseClosingStep()
            case .complete:
                CompleteStep()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(CalmTheme.cardStroke, lineWidth: 1)
                )
                .shadow(color: CalmTheme.shadow, radius: 12, y: 8)
        )
        .transition(.opacity.combined(with: .move(edge: .trailing)))
    }

    private var navigationRow: some View {
        HStack(spacing: 12) {
            if viewModel.step != .arrive {
                Button("Back") {
                    LightHaptics.tap()
                    viewModel.back()
                }
                .buttonStyle(SecondaryOutlineButtonStyle())
                .accessibilityIdentifier("backButton")
            }

            Button(viewModel.primaryButtonTitle) {
                LightHaptics.tap()
                viewModel.next()
            }
            .buttonStyle(PrimaryButtonStyle())
            .accessibilityIdentifier(primaryButtonIdentifier)
            .disabled(!viewModel.canMoveForward)
            .opacity(viewModel.canMoveForward ? 1 : 0.45)
        }
    }

    private var primaryButtonIdentifier: String {
        switch viewModel.step {
        case .arrive:
            return "startResetButton"
        case .dump:
            return "continueFromDumpButton"
        case .categorize:
            return "continueFromCategoriesButton"
        case .chooseAction:
            return "continueFromActionButton"
        case .chooseClosing:
            return "finishResetButton"
        case .complete:
            return "resetAgainButton"
        }
    }
}

private struct ArriveStep: View {
    @EnvironmentObject private var viewModel: EverythingModeViewModel

    private var lastResetText: String {
        guard let summary = viewModel.lastSummary else {
            return "No streaks, no scores, no pressure. Just relief."
        }

        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        let when = formatter.localizedString(for: summary.timestamp, relativeTo: Date())
        return "Last reset \(when): \"\(summary.action)\""
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Everything feels like too much right now.")
                .font(.system(size: 26, weight: .semibold, design: .rounded))
                .foregroundStyle(CalmTheme.primaryText)

            Text("We are not fixing your whole life. We are making the next 15 minutes gentler.")
                .font(.system(size: 17))
                .foregroundStyle(CalmTheme.secondaryText)

            Text(lastResetText)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(CalmTheme.secondaryText)
                .padding(.top, 4)
        }
    }
}

private struct DumpStep: View {
    @EnvironmentObject private var viewModel: EverythingModeViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Put it down here")
                .font(.system(size: 24, weight: .semibold, design: .rounded))
                .foregroundStyle(CalmTheme.primaryText)

            Text("Ramble if you need to. Messy is welcome.")
                .font(.system(size: 16))
                .foregroundStyle(CalmTheme.secondaryText)

            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(CalmTheme.inputBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(CalmTheme.cardStroke, lineWidth: 1)
                    )

                if viewModel.brainDump.isEmpty {
                    Text("money, inbox, laundry, hard conversation, body tension, all of it...")
                        .foregroundStyle(CalmTheme.secondaryText.opacity(0.65))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 16)
                }

                TextEditor(text: $viewModel.brainDump)
                    .scrollContentBackground(.hidden)
                    .foregroundStyle(CalmTheme.primaryText)
                    .accessibilityIdentifier("brainDumpEditor")
                    .padding(10)
                    .frame(minHeight: 250, maxHeight: 330)
            }

            Text("You only need enough words to breathe a little easier.")
                .font(.system(size: 13))
                .foregroundStyle(CalmTheme.secondaryText)
        }
    }
}

private struct CategorizeStep: View {
    @EnvironmentObject private var viewModel: EverythingModeViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Give it a few buckets")
                .font(.system(size: 24, weight: .semibold, design: .rounded))
                .foregroundStyle(CalmTheme.primaryText)

            Text("Pick up to three. This is for clarity, not perfection.")
                .font(.system(size: 16))
                .foregroundStyle(CalmTheme.secondaryText)

            VStack(spacing: 10) {
                ForEach(WeightCategory.allCases) { category in
                    let selected = viewModel.selectedCategories.contains(category)
                    Button {
                        LightHaptics.tap()
                        viewModel.toggleCategory(category)
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(selected ? CalmTheme.primaryAction : CalmTheme.secondaryText)
                            VStack(alignment: .leading, spacing: 3) {
                                Text(category.title)
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundStyle(CalmTheme.primaryText)
                                Text(category.hint)
                                    .font(.system(size: 13))
                                    .foregroundStyle(CalmTheme.secondaryText)
                            }
                            Spacer()
                        }
                        .padding(12)
                        .background(CalmTheme.inputBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(selected ? CalmTheme.primaryAction : CalmTheme.cardStroke, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("category_\(category.rawValue)")
                }
            }
        }
    }
}

private struct ChooseActionStep: View {
    @EnvironmentObject private var viewModel: EverythingModeViewModel

    private let actionLimit = 120

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Choose one relief move")
                .font(.system(size: 24, weight: .semibold, design: .rounded))
                .foregroundStyle(CalmTheme.primaryText)

            Text("Just one thing that makes this moment lighter.")
                .font(.system(size: 16))
                .foregroundStyle(CalmTheme.secondaryText)

            TextField("Reply with one sentence to Sam", text: actionBinding)
                .textInputAutocapitalization(.sentences)
                .foregroundStyle(CalmTheme.primaryText)
                .accessibilityIdentifier("actionTextField")
                .padding(14)
                .background(CalmTheme.inputBackground)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(CalmTheme.cardStroke, lineWidth: 1)
                )

            Text("\(viewModel.chosenAction.count)/\(actionLimit)")
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundStyle(CalmTheme.secondaryText)
        }
    }

    private var actionBinding: Binding<String> {
        Binding(
            get: { viewModel.chosenAction },
            set: { viewModel.chosenAction = String($0.prefix(actionLimit)) }
        )
    }
}

private struct ChooseClosingStep: View {
    @EnvironmentObject private var viewModel: EverythingModeViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("What counts as done today?")
                .font(.system(size: 24, weight: .semibold, design: .rounded))
                .foregroundStyle(CalmTheme.primaryText)

            Text("\"\(viewModel.chosenAction)\"")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(CalmTheme.secondaryText)

            VStack(spacing: 10) {
                ForEach(ClosingChoice.allCases) { choice in
                    let selected = viewModel.closingChoice == choice
                    Button {
                        LightHaptics.tap()
                        viewModel.closingChoice = choice
                    } label: {
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(selected ? CalmTheme.primaryAction : CalmTheme.secondaryText)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(choice.title)
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundStyle(CalmTheme.primaryText)
                                Text(choice.detail)
                                    .font(.system(size: 14))
                                    .foregroundStyle(CalmTheme.secondaryText)
                            }
                            Spacer()
                        }
                        .padding(12)
                        .background(CalmTheme.inputBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(selected ? CalmTheme.primaryAction : CalmTheme.cardStroke, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("closing_\(choice.rawValue)")
                }
            }
        }
    }
}

private struct CompleteStep: View {
    @EnvironmentObject private var viewModel: EverythingModeViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("You can stop here.")
                .font(.system(size: 26, weight: .semibold, design: .rounded))
                .foregroundStyle(CalmTheme.primaryText)

            Text("You named it, sorted it, and chose one clear move.")
                .font(.system(size: 17))
                .foregroundStyle(CalmTheme.secondaryText)

            Group {
                Text("Categories: \(viewModel.selectedCategoriesText)")
                Text("One move: \(viewModel.chosenAction)")
                if let closingChoice = viewModel.closingChoice {
                    Text("Closing choice: \(closingChoice.title)")
                }
            }
            .font(.system(size: 15, weight: .medium))
            .foregroundStyle(CalmTheme.secondaryText)

            Text("Close the app whenever you want. No extra steps.")
                .font(.system(size: 15))
                .foregroundStyle(CalmTheme.secondaryText)
                .padding(.top, 4)
        }
        .accessibilityIdentifier("completeStep")
    }
}

#Preview {
    RootView()
        .environmentObject(EverythingModeViewModel())
}

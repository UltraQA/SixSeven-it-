import SwiftUI
import SixSevenCore

public struct HomeView<Provider: FlipOutcomeProviding>: View {
    @StateObject private var viewModel: HomeViewModel<Provider>
    @StateObject private var settingsViewModel: SettingsViewModel
    @Environment(\.scenePhase) private var scenePhase
    private let motionClient: any MotionClient

    public init(
        provider: Provider,
        feedback: any FlipFeedbackClient = NoOpFlipFeedbackClient(),
        motionClient: any MotionClient = NoOpMotionClient(),
        settingsStore: any SettingsStore = UserDefaultsSettingsStore()
    ) {
        self.motionClient = motionClient
        _viewModel = StateObject(
            wrappedValue: HomeViewModel(
                provider: provider,
                settingsStore: settingsStore,
                feedback: feedback
            )
        )
        _settingsViewModel = StateObject(
            wrappedValue: SettingsViewModel(store: settingsStore)
        )
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: SixSevenSpacing.large) {
                    header
                    questionField
                    coinStage
                    actionArea
                }
                .padding(.horizontal, SixSevenSpacing.standard)
                .padding(.top, SixSevenSpacing.small)
                .padding(.bottom, SixSevenSpacing.hero)
            }
            .background(SixSevenColors.backgroundPrimary.ignoresSafeArea())
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .toolbar {
                ToolbarItemGroup(placement: .automatic) {
                    NavigationLink {
                        StatsView(statistics: viewModel.statistics)
                    } label: {
                        Image(systemName: "chart.bar")
                    }
                    .accessibilityLabel("Stats")
                    .accessibilityIdentifier(SixSevenAccessibility.statsButton)

                    NavigationLink {
                        SettingsView(viewModel: settingsViewModel)
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityLabel("Settings")
                    .accessibilityIdentifier(SixSevenAccessibility.settingsButton)
                }
            }
            .task {
                let events = motionClient.shakeEvents()
                await motionClient.start()
                await viewModel.refreshSettings()

                for await _ in events {
                    viewModel.handleShake()
                }

                await motionClient.stop()
            }
            .onChange(of: settingsViewModel.settings) { _, settings in
                viewModel.apply(settings: settings)
            }
            .onDisappear {
                viewModel.cancelPendingFlip()
            }
            .onChange(of: scenePhase) { _, phase in
                guard phase != .active else { return }
                viewModel.cancelPendingFlip()
            }
        }
    }

    private var header: some View {
        VStack(spacing: SixSevenSpacing.compact) {
            Text("CAN'T DECIDE?")
                .font(SixSevenTypography.eyebrow)
                .tracking(1.8)
                .foregroundStyle(SixSevenColors.contentSecondary)
            Text("Sixseven it.")
                .font(SixSevenTypography.hero)
                .foregroundStyle(SixSevenColors.contentPrimary)
            if let question = result?.question, !question.isEmpty {
                Text("“\(question)”")
                    .font(SixSevenTypography.callout)
                    .foregroundStyle(SixSevenColors.contentSecondary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
                    .frame(maxWidth: .infinity)
            } else {
                Text("Let the numbers make the call.")
                    .font(SixSevenTypography.callout)
                    .foregroundStyle(SixSevenColors.contentSecondary)
            }
        }
        .multilineTextAlignment(.center)
    }

    private var questionField: some View {
        SixSevenCard {
            VStack(alignment: .leading, spacing: SixSevenSpacing.small) {
                Text("WHAT'S THE MOVE?")
                    .font(SixSevenTypography.eyebrow)
                    .tracking(1.2)
                    .foregroundStyle(SixSevenColors.contentSecondary)

                TextField(
                    "What are you deciding?",
                    text: Binding(
                        get: { viewModel.question },
                        set: { viewModel.question = $0 }
                    ),
                    axis: .vertical
                )
                .font(SixSevenTypography.body)
                .lineLimit(1...3)
                .submitLabel(.done)
                .disabled(viewModel.isFlipping)
                .accessibilityIdentifier(SixSevenAccessibility.questionInput)
                .accessibilityLabel("Decision question")

                HStack {
                    Spacer()
                    Text("\(viewModel.question.count)/\(SixSevenQuestionMetrics.maxLength)")
                        .font(SixSevenTypography.caption)
                        .foregroundStyle(SixSevenColors.contentSecondary)
                        .monospacedDigit()
                        .accessibilityLabel("\(viewModel.question.count) of \(SixSevenQuestionMetrics.maxLength) characters")
                }
            }
        }
    }

    private var coinStage: some View {
        VStack(spacing: SixSevenSpacing.compact) {
            CoinView(
                outcome: viewModel.currentOutcome,
                isFlipping: viewModel.isFlipping
            )
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 24)
                    .onEnded { value in
                        guard value.translation.height < -60,
                              abs(value.translation.height) > abs(value.translation.width) else { return }
                        viewModel.handleSwipeUp()
                    }
            )
            .accessibilityHint("Swipe up to flip")

            if viewModel.currentOutcome == nil && !viewModel.isFlipping {
                Label("Swipe up to flip", systemImage: "arrow.up")
                    .font(SixSevenTypography.caption)
                    .foregroundStyle(SixSevenColors.contentSecondary)
                    .accessibilityHidden(true)
            }
        }
    }

    private var actionArea: some View {
        VStack(spacing: SixSevenSpacing.standard) {
            resultLabel

            Button {
                if viewModel.currentOutcome == nil {
                    viewModel.flip()
                } else {
                    viewModel.flipAgain()
                }
            } label: {
                Label(
                    "Flip it!",
                    systemImage: "arrow.triangle.2.circlepath"
                )
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(SixSevenPrimaryButtonStyle())
            .disabled(viewModel.isFlipInteractionLocked)
            .accessibilityIdentifier(SixSevenAccessibility.flipButton)
            .accessibilityHint(viewModel.isFlipInteractionLocked ? "Wait a moment before flipping again" : "Starts a coin flip")

            if let result {
                ShareLink(item: SharePayload.text(for: result)) {
                    Label("Share result", systemImage: "square.and.arrow.up")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(SixSevenSecondaryButtonStyle())
                .accessibilityIdentifier(SixSevenAccessibility.shareButton)
            }
        }
    }

    private var resultLabel: some View {
        Group {
            if let outcome = viewModel.currentOutcome {
                Text(resultText(for: outcome))
                    .font(SixSevenTypography.display)
                    .foregroundStyle(outcomeColor(for: outcome))
                    .accessibilityAddTraits(.isHeader)
            } else {
                Text("Ready when you are")
                    .font(SixSevenTypography.callout)
                    .foregroundStyle(SixSevenColors.contentSecondary)
                    .accessibilityHidden(true)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 32)
    }

    private var result: FlipResult? {
        guard case let .result(result) = viewModel.state.phase else { return nil }
        return result
    }

    private func resultText(for outcome: Outcome) -> String {
        switch outcome {
        case .six: "It's a 6"
        case .seven: "It's a 7"
        case .sixtySeven: "SIX SEVEN!"
        }
    }

    private func outcomeColor(for outcome: Outcome) -> Color {
        switch outcome {
        case .six: SixSevenColors.accentSix
        case .seven: SixSevenColors.accentSeven
        case .sixtySeven: SixSevenColors.accentRare
        }
    }
}

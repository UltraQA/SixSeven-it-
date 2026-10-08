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
                    CoinView(
                        outcome: viewModel.currentOutcome,
                        isFlipping: viewModel.isFlipping
                    )
                    actionArea
                }
                .padding(.horizontal, SixSevenSpacing.standard)
                .padding(.vertical, SixSevenSpacing.hero)
            }
            .background(SixSevenColors.background.ignoresSafeArea())
            .navigationTitle("SixSeven it!")
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
        VStack(spacing: SixSevenSpacing.small) {
            Text("Can't decide?")
                .font(.title2.weight(.semibold))
            Text("Sixseven it.")
                .font(.largeTitle.bold())
        }
        .foregroundStyle(SixSevenColors.content)
        .multilineTextAlignment(.center)
    }

    private var questionField: some View {
        TextField(
            "What are you deciding?",
            text: Binding(
                get: { viewModel.question },
                set: { viewModel.question = $0 }
            ),
            axis: .vertical
        )
        .textFieldStyle(.roundedBorder)
        .lineLimit(1...3)
        .submitLabel(.done)
        .disabled(viewModel.isFlipping)
        .accessibilityIdentifier(SixSevenAccessibility.questionInput)
        .accessibilityLabel("Decision question")
    }

    private var actionArea: some View {
        VStack(spacing: SixSevenSpacing.standard) {
            if let outcome = viewModel.currentOutcome {
                Text(resultText(for: outcome))
                    .font(.title2.bold())
                    .foregroundStyle(outcome == .sixtySeven ? SixSevenColors.rare : SixSevenColors.content)
                    .accessibilityAddTraits(.isHeader)

                if let result {
                    ShareLink(item: SharePayload.text(for: result)) {
                        Label("Share result", systemImage: "square.and.arrow.up")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .accessibilityIdentifier(SixSevenAccessibility.shareButton)
                }
            }

            Button {
                if viewModel.currentOutcome == nil {
                    viewModel.flip()
                } else {
                    viewModel.flipAgain()
                }
            } label: {
                Text(viewModel.currentOutcome == nil ? "Flip it" : "Flip again")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(viewModel.isFlipping)
            .accessibilityIdentifier(SixSevenAccessibility.flipButton)
            .accessibilityHint(viewModel.isFlipping ? "Wait for the result" : "Starts a coin flip")
        }
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
}

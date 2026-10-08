import SwiftUI
import SixSevenCore

public struct HomeView<Provider: FlipOutcomeProviding>: View {
    @StateObject private var viewModel: HomeViewModel<Provider>
    @StateObject private var settingsViewModel: SettingsViewModel
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @FocusState private var isQuestionFieldFocused: Bool
    @State private var isSwipeHintPulsing = false
    private let motionClient: any MotionClient

    public init(
        provider: Provider,
        feedback: any FlipFeedbackClient = NoOpFlipFeedbackClient(),
        motionClient: any MotionClient = NoOpMotionClient(),
        statisticsStore: any StatisticsStore = UserDefaultsStatisticsStore(),
        settingsStore: any SettingsStore = UserDefaultsSettingsStore()
    ) {
        self.motionClient = motionClient
        _viewModel = StateObject(
            wrappedValue: HomeViewModel(
                provider: provider,
                statisticsStore: statisticsStore,
                settingsStore: settingsStore,
                feedback: feedback
            )
        )
        _settingsViewModel = StateObject(
            wrappedValue: SettingsViewModel(store: settingsStore)
        )
    }

    public var body: some View {
        GeometryReader { proxy in
            NavigationStack {
                ScrollView {
                    VStack(spacing: SixSevenSpacing.large) {
                        header
                        coinInteractionZone
                        swipeSurface
                    }
                    .padding(.horizontal, SixSevenSpacing.standard)
                    .padding(.top, SixSevenSpacing.small)
                    .padding(.bottom, SixSevenSpacing.hero)
                    .frame(maxWidth: .infinity, minHeight: proxy.size.height)
                }
                .scrollDisabled(!dynamicTypeSize.isAccessibilitySize)
                .background {
                    SixSevenColors.backgroundPrimary
                        .ignoresSafeArea()
                        .contentShape(Rectangle())
                }
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
        VStack(alignment: .leading, spacing: SixSevenSpacing.small) {
            Text("THE 6/7 CALL")
                .font(SixSevenTypography.eyebrow)
                .tracking(1.2)
                .foregroundStyle(SixSevenColors.contentSecondary)

            TextField(
                "Drop your dilemma here…",
                text: Binding(
                    get: { viewModel.question },
                    set: { viewModel.question = $0 }
                ),
                axis: .vertical
            )
            .font(SixSevenTypography.body)
            .lineLimit(1...3)
            .submitLabel(.done)
            .focused($isQuestionFieldFocused)
            .disabled(viewModel.isFlipping)
            .accessibilityIdentifier(SixSevenAccessibility.questionInput)
            .accessibilityLabel("Decision question")
            .padding(.vertical, SixSevenSpacing.small)
        }
        .padding(.horizontal, SixSevenSpacing.hairline)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(SixSevenColors.separator.opacity(0.7))
                .frame(height: 1)
        }
    }

    private var coinInteractionZone: some View {
        VStack(spacing: SixSevenSpacing.large) {
            questionField
            coinStage
            actionArea
        }
        .contentShape(Rectangle())
        .simultaneousGesture(upwardSwipeGesture)
    }

    private var swipeSurface: some View {
        Spacer(minLength: 0)
            .frame(maxWidth: .infinity, minHeight: SixSevenSwipeMetrics.minimumSurfaceHeight)
            .background(SixSevenColors.backgroundPrimary.opacity(0.001))
            .contentShape(Rectangle())
            .gesture(upwardSwipeGesture)
            .accessibilityLabel("Swipe up to flip")
            .accessibilityHint("Swipe up anywhere below the result")
            .accessibilityIdentifier(SixSevenAccessibility.swipeSurface)
    }

    private var coinStage: some View {
        VStack(spacing: SixSevenSpacing.compact) {
            CoinView(
                outcome: viewModel.currentOutcome,
                isFlipping: viewModel.isFlipping,
                flipCount: viewModel.statistics.totalFlips
            )
            .contentShape(Rectangle())
            .accessibilityHint("Swipe up anywhere below the header to flip")
            .simultaneousGesture(upwardSwipeGesture)

            if viewModel.currentOutcome == nil && !viewModel.isFlipping {
                HStack(spacing: SixSevenSpacing.small) {
                    Image(systemName: "arrow.up")
                        .frame(width: SixSevenSpacing.standard, height: SixSevenSpacing.standard)
                        .scaleEffect(isSwipeHintPulsing && !reduceMotion ? 1.15 : 1)
                        .animation(
                            reduceMotion
                                ? nil
                                : .easeInOut(duration: 0.9).repeatForever(autoreverses: true),
                            value: isSwipeHintPulsing
                        )
                    Text("Swipe up to flip")
                }
                    .font(SixSevenTypography.caption)
                    .foregroundStyle(SixSevenColors.contentSecondary)
                    .accessibilityHidden(true)
                    .onAppear {
                        isSwipeHintPulsing = !reduceMotion
                    }
                    .onChange(of: reduceMotion) { _, newValue in
                        isSwipeHintPulsing = !newValue
                    }
            }
        }
    }

    private var actionArea: some View {
        VStack(spacing: SixSevenSpacing.standard) {
            resultLabel

            if let result {
                ShareLink(item: SharePayload.text(for: result)) {
                    Label("Share result", systemImage: "square.and.arrow.up")
                        .font(SixSevenTypography.title)
                        .foregroundStyle(SixSevenColors.contentPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 44)
                }
                .buttonStyle(.plain)
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

    private var upwardSwipeGesture: some Gesture {
        DragGesture(minimumDistance: 24)
            .onEnded { value in
                guard value.translation.height < -60,
                      abs(value.translation.height) > abs(value.translation.width) else { return }
                isQuestionFieldFocused = false
                viewModel.handleSwipeUp()
            }
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

import XCTest
@testable import SixSevenCore
@testable import SixSevenUI

@MainActor
final class HomeViewModelTests: XCTestCase {
    func testFlipCompletesWithProviderOutcomeAndRejectsConcurrentFlip() async {
        let feedback = RecordingFeedbackClient()
        let viewModel = HomeViewModel(
            provider: SequenceOutcomeProvider(outcomes: [.sixtySeven]),
            state: GameState(question: "Should I go?"),
            statisticsStore: TestStatisticsStore(),
            settingsStore: TestSettingsStore(),
            feedback: feedback,
            animationDuration: .zero
        )

        viewModel.flip()
        viewModel.flip()
        XCTAssertTrue(viewModel.isFlipping)

        await yieldToPendingTasks()

        XCTAssertEqual(viewModel.currentOutcome, .sixtySeven)
        XCTAssertEqual(viewModel.statistics.totalFlips, 1)
        let launchCount = await feedback.launchCount
        let rareResultCount = await feedback.rareResultCount
        XCTAssertEqual(launchCount, 1)
        XCTAssertEqual(rareResultCount, 1)
    }

    func testShakeDoesNothingWhenMotionControlIsDisabled() async {
        let viewModel = HomeViewModel(
            provider: SequenceOutcomeProvider(outcomes: [.six]),
            statisticsStore: TestStatisticsStore(),
            settingsStore: TestSettingsStore(settings: AppSettings(motionControlEnabled: false)),
            animationDuration: .zero
        )

        await viewModel.refreshSettings()
        viewModel.handleShake()

        XCTAssertFalse(viewModel.isFlipping)
        XCTAssertNil(viewModel.currentOutcome)
    }

    func testShakeStartsFlipWhenMotionControlIsEnabled() async {
        let viewModel = HomeViewModel(
            provider: SequenceOutcomeProvider(outcomes: [.seven]),
            statisticsStore: TestStatisticsStore(),
            settingsStore: TestSettingsStore(settings: AppSettings(motionControlEnabled: true)),
            animationDuration: .zero
        )

        await viewModel.refreshSettings()
        viewModel.handleShake()
        await yieldToPendingTasks()

        XCTAssertEqual(viewModel.currentOutcome, .seven)
    }

    func testApplyingSettingsUpdatesMotionPolicyImmediately() async {
        let viewModel = HomeViewModel(
            provider: SequenceOutcomeProvider(outcomes: [.six]),
            statisticsStore: TestStatisticsStore(),
            settingsStore: TestSettingsStore(),
            animationDuration: .zero
        )

        viewModel.apply(settings: AppSettings(motionControlEnabled: true))
        viewModel.handleShake()
        await yieldToPendingTasks()

        XCTAssertEqual(viewModel.currentOutcome, .six)
    }

    func testSwipeUpStartsInitialFlip() async {
        let viewModel = HomeViewModel(
            provider: SequenceOutcomeProvider(outcomes: [.seven]),
            statisticsStore: TestStatisticsStore(),
            settingsStore: TestSettingsStore(),
            animationDuration: .zero
        )

        viewModel.handleSwipeUp()
        await yieldToPendingTasks()

        XCTAssertEqual(viewModel.currentOutcome, .seven)
    }

    func testForceOutcomeSelectsRequestedResult() async {
        let viewModel = HomeViewModel(
            provider: SequenceOutcomeProvider(outcomes: [.six]),
            statisticsStore: TestStatisticsStore(),
            settingsStore: TestSettingsStore(),
            animationDuration: .zero
        )

        viewModel.forceOutcome(.sixtySeven)
        await yieldToPendingTasks()

        XCTAssertEqual(viewModel.currentOutcome, .sixtySeven)
    }

    func testQuestionClearsAfterFlipWhileResultKeepsOriginalQuestion() async {
        let viewModel = HomeViewModel(
            provider: SequenceOutcomeProvider(outcomes: [.six]),
            state: GameState(question: "Should I go?"),
            statisticsStore: TestStatisticsStore(),
            settingsStore: TestSettingsStore(),
            animationDuration: .zero
        )

        viewModel.flip()
        await yieldToPendingTasks()

        XCTAssertEqual(viewModel.question, "")
        guard case let .result(result) = viewModel.state.phase else {
            return XCTFail("Expected a completed result")
        }
        XCTAssertEqual(result.outcome, .six)
        XCTAssertEqual(result.question, "Should I go?")
    }

    func testFlipAgainCompletesSecondFlipAndRecordsItOnce() async {
        let viewModel = HomeViewModel(
            provider: SequenceOutcomeProvider(outcomes: [.six, .seven]),
            statisticsStore: TestStatisticsStore(),
            settingsStore: TestSettingsStore(),
            animationDuration: .zero,
            resultCooldownDuration: .zero
        )

        viewModel.flip()
        await yieldToPendingTasks()
        XCTAssertEqual(viewModel.currentOutcome, .six)

        viewModel.flipAgain()
        await yieldToPendingTasks()

        XCTAssertEqual(viewModel.currentOutcome, .seven)
        XCTAssertEqual(viewModel.statistics.totalFlips, 2)
        XCTAssertEqual(viewModel.statistics.sixCount, 1)
        XCTAssertEqual(viewModel.statistics.sevenCount, 1)
    }

    func testResultCooldownBlocksImmediateSecondFlip() async {
        let viewModel = HomeViewModel(
            provider: SequenceOutcomeProvider(outcomes: [.six, .seven]),
            statisticsStore: TestStatisticsStore(),
            settingsStore: TestSettingsStore(),
            animationDuration: .zero,
            resultCooldownDuration: .seconds(1)
        )

        viewModel.flip()
        await yieldToPendingTasks()

        XCTAssertEqual(viewModel.currentOutcome, .six)
        XCTAssertTrue(viewModel.isResultCoolingDown)

        viewModel.flipAgain()
        await yieldToPendingTasks()

        XCTAssertEqual(viewModel.statistics.totalFlips, 1)
        XCTAssertFalse(viewModel.isFlipping)
        viewModel.cancelPendingFlip()
    }

    func testQuestionIsCappedAtMaximumLength() {
        let viewModel = HomeViewModel(
            provider: SequenceOutcomeProvider(outcomes: [.six]),
            statisticsStore: TestStatisticsStore(),
            settingsStore: TestSettingsStore()
        )
        let oversizedQuestion = String(
            repeating: "a",
            count: SixSevenQuestionMetrics.maxLength + 20
        )

        viewModel.question = oversizedQuestion

        XCTAssertEqual(viewModel.question.count, SixSevenQuestionMetrics.maxLength)
    }

    private func yieldToPendingTasks() async {
        for _ in 0..<20 {
            await Task.yield()
        }
    }
}

private struct SequenceOutcomeProvider: FlipOutcomeProviding {
    private var outcomes: [Outcome]
    private var index = 0

    init(outcomes: [Outcome]) {
        self.outcomes = outcomes
    }

    mutating func makeOutcome() -> Outcome {
        defer { index += 1 }
        return outcomes[min(index, outcomes.count - 1)]
    }
}

private actor TestStatisticsStore: StatisticsStore {
    private var statistics: Statistics = .empty

    func load() async throws -> Statistics {
        statistics
    }

    func save(_ statistics: Statistics) async throws {
        self.statistics = statistics
    }
}

private actor TestSettingsStore: SettingsStore {
    private let settings: AppSettings

    init(settings: AppSettings = .defaults) {
        self.settings = settings
    }

    func load() async throws -> AppSettings {
        settings
    }

    func save(_ settings: AppSettings) async throws {}
}

private actor RecordingFeedbackClient: FlipFeedbackClient {
    private(set) var launchCount = 0
    private(set) var rareResultCount = 0

    func playLaunch(soundEffectsEnabled: Bool) async {
        launchCount += 1
    }

    func playResult(for outcome: Outcome, soundEffectsEnabled: Bool) async {
        if outcome == .sixtySeven {
            rareResultCount += 1
        }
    }
}

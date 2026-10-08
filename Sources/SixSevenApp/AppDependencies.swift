import SixSevenCore

struct AppDependencies {
    let outcomeProvider: WeightedOutcomeProvider<SystemRandomNumberGeneratorAdapter>
    let statisticsStore: any StatisticsStore
    let settingsStore: any SettingsStore
    let feedback: any FlipFeedbackClient
    let motion: any MotionClient

    init() {
        outcomeProvider = WeightedOutcomeProvider(
            generator: SystemRandomNumberGeneratorAdapter()
        )
        statisticsStore = UserDefaultsStatisticsStore()
        settingsStore = UserDefaultsSettingsStore()

#if os(iOS)
        feedback = SystemFlipFeedbackClient(
            haptics: SystemHapticsClient(),
            audio: SystemAudioClient()
        )
        motion = SystemMotionClient()
#else
        feedback = NoOpFlipFeedbackClient()
        motion = NoOpMotionClient()
#endif
    }
}

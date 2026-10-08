import SwiftUI
import SixSevenCore
import SixSevenUI

@main
struct SixSevenApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView(
                provider: WeightedOutcomeProvider(
                    generator: SystemRandomNumberGeneratorAdapter()
                ),
                feedback: feedbackClient,
                motionClient: motionClient
            )
        }
    }

    private var feedbackClient: any FlipFeedbackClient {
#if os(iOS)
        return SystemFlipFeedbackClient(
            haptics: SystemHapticsClient(),
            audio: SystemAudioClient()
        )
#else
        return NoOpFlipFeedbackClient()
#endif
    }

    private var motionClient: any MotionClient {
#if os(iOS)
        return SystemMotionClient()
#else
        return NoOpMotionClient()
#endif
    }
}

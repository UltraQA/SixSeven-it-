import SwiftUI
import SixSevenCore
import SixSevenUI

@main
struct SixSevenApp: App {
    private let dependencies = AppDependencies()

    var body: some Scene {
        WindowGroup {
            HomeView(
                provider: dependencies.outcomeProvider,
                feedback: dependencies.feedback,
                motionClient: dependencies.motion,
                statisticsStore: dependencies.statisticsStore,
                settingsStore: dependencies.settingsStore
            )
        }
    }
}

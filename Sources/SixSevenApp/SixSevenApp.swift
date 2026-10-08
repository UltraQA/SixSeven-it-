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
                )
            )
        }
    }
}

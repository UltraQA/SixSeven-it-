import XCTest
@testable import SixSevenCore

final class SystemClientsTests: XCTestCase {
    func testNoOpMotionClientFinishesWithoutEvents() async {
        let client = NoOpMotionClient()
        var eventCount = 0

        for await _ in client.shakeEvents() {
            eventCount += 1
        }

        XCTAssertEqual(eventCount, 0)
    }

    func testNoOpClientsAreSafeToCall() async {
        let haptics = NoOpHapticsClient()
        let audio = NoOpAudioClient()

        await haptics.prepare()
        await haptics.playLaunch()
        await haptics.playResult()
        await haptics.playRareResult()
        await haptics.stop()
        await audio.playFlip()
        await audio.playResult()
        await audio.playRareResult()
        await audio.stop()
    }
}

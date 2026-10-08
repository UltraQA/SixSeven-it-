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

    func testFeedbackRespectsSoundEffectsSetting() async {
        let haptics = RecordingHapticsClient()
        let audio = RecordingAudioClient()
        let feedback = SystemFlipFeedbackClient(haptics: haptics, audio: audio)

        await feedback.playLaunch(soundEffectsEnabled: false)
        await feedback.playResult(for: .sixtySeven, soundEffectsEnabled: false)

        let launchCountWithoutSound = await haptics.launchCount
        let rareHapticCountWithoutSound = await haptics.rareResultCount
        let flipCountWithoutSound = await audio.flipCount
        let rareAudioCountWithoutSound = await audio.rareResultCount

        XCTAssertEqual(launchCountWithoutSound, 1)
        XCTAssertEqual(rareHapticCountWithoutSound, 1)
        XCTAssertEqual(flipCountWithoutSound, 0)
        XCTAssertEqual(rareAudioCountWithoutSound, 0)

        await feedback.playLaunch(soundEffectsEnabled: true)
        await feedback.playResult(for: .six, soundEffectsEnabled: true)

        let flipCountWithSound = await audio.flipCount
        let resultCountWithSound = await audio.resultCount

        XCTAssertEqual(flipCountWithSound, 1)
        XCTAssertEqual(resultCountWithSound, 1)
    }
}

private actor RecordingHapticsClient: HapticsClient {
    private(set) var launchCount = 0
    private(set) var rareResultCount = 0

    func prepare() async {}

    func playLaunch() async {
        launchCount += 1
    }

    func playResult() async {}

    func playRareResult() async {
        rareResultCount += 1
    }

    func stop() async {}
}

private actor RecordingAudioClient: AudioClient {
    private(set) var flipCount = 0
    private(set) var resultCount = 0
    private(set) var rareResultCount = 0

    func playFlip() async {
        flipCount += 1
    }

    func playResult() async {
        resultCount += 1
    }

    func playRareResult() async {
        rareResultCount += 1
    }

    func stop() async {}
}

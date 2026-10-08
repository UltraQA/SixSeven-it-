import SixSevenCore

public struct FlipFeedback<Haptics: HapticsClient, Audio: AudioClient>: FlipFeedbackClient {
    private let haptics: Haptics
    private let audio: Audio

    public init(haptics: Haptics, audio: Audio) {
        self.haptics = haptics
        self.audio = audio
    }

    public func playLaunch() async {
        await haptics.playLaunch()
        await audio.playFlip()
    }

    public func playResult(for outcome: Outcome) async {
        switch outcome {
        case .sixtySeven:
            await haptics.playRareResult()
            await audio.playRareResult()
        case .six, .seven:
            await haptics.playResult()
            await audio.playResult()
        }
    }
}

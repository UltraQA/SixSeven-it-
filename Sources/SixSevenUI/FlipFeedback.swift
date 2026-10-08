import SixSevenCore

public struct FlipFeedback<Haptics: HapticsClient, Audio: AudioClient>: FlipFeedbackClient {
    private let haptics: Haptics
    private let audio: Audio

    public init(haptics: Haptics, audio: Audio) {
        self.haptics = haptics
        self.audio = audio
    }

    public func playLaunch(soundEffectsEnabled: Bool) async {
        await haptics.playLaunch()
        if soundEffectsEnabled {
            await audio.playFlip()
        }
    }

    public func playResult(for outcome: Outcome, soundEffectsEnabled: Bool) async {
        switch outcome {
        case .sixtySeven:
            await haptics.playRareResult()
            if soundEffectsEnabled {
                await audio.playRareResult()
            }
        case .six, .seven:
            await haptics.playResult()
            if soundEffectsEnabled {
                await audio.playResult()
            }
        }
    }
}

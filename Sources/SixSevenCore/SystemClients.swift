import Foundation

public protocol HapticsClient: Sendable {
    func prepare() async
    func playLaunch() async
    func playResult() async
    func playRareResult() async
    func stop() async
}

public struct NoOpHapticsClient: HapticsClient {
    public init() {}

    public func prepare() async {}
    public func playLaunch() async {}
    public func playResult() async {}
    public func playRareResult() async {}
    public func stop() async {}
}

public protocol AudioClient: Sendable {
    func playFlip() async
    func playResult() async
    func playRareResult() async
    func stop() async
}

public protocol FlipFeedbackClient: Sendable {
    func playLaunch(soundEffectsEnabled: Bool) async
    func playResult(for outcome: Outcome, soundEffectsEnabled: Bool) async
}

public struct NoOpFlipFeedbackClient: FlipFeedbackClient {
    public init() {}

    public func playLaunch(soundEffectsEnabled: Bool) async {}
    public func playResult(for outcome: Outcome, soundEffectsEnabled: Bool) async {}
}

public struct SystemFlipFeedbackClient: FlipFeedbackClient {
    private let haptics: any HapticsClient
    private let audio: any AudioClient

    public init(haptics: any HapticsClient, audio: any AudioClient) {
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

public struct NoOpAudioClient: AudioClient {
    public init() {}

    public func playFlip() async {}
    public func playResult() async {}
    public func playRareResult() async {}
    public func stop() async {}
}

public protocol MotionClient: Sendable {
    func shakeEvents() -> AsyncStream<Void>
    func start() async
    func stop() async
}

public struct NoOpMotionClient: MotionClient {
    public init() {}

    public func shakeEvents() -> AsyncStream<Void> {
        AsyncStream { continuation in
            continuation.finish()
        }
    }

    public func start() async {}
    public func stop() async {}
}

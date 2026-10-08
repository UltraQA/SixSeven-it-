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

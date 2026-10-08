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

#if canImport(CoreHaptics) && os(iOS)
import CoreHaptics

@available(iOS 13.0, *)
public final class SystemHapticsClient: HapticsClient, @unchecked Sendable {
    private var engine: CHHapticEngine?

    public init() {}

    public func prepare() async {
        ensureEngine()
    }

    public func playLaunch() async {
        play(intensity: 0.45, sharpness: 0.55)
    }

    public func playResult() async {
        play(intensity: 0.7, sharpness: 0.6)
    }

    public func playRareResult() async {
        play(intensity: 1.0, sharpness: 0.8)
    }

    public func stop() async {
        try? await engine?.stop()
        engine = nil
    }

    private func ensureEngine() {
        guard engine == nil, CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        do {
            let newEngine = try CHHapticEngine()
            newEngine.resetHandler = { [weak self] in
                self?.engine = nil
                self?.ensureEngine()
            }
            try newEngine.start()
            engine = newEngine
        } catch {
            engine = nil
        }
    }

    private func play(intensity: Float, sharpness: Float) {
        ensureEngine()
        guard let engine else { return }

        let event = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
            ],
            relativeTime: 0
        )

        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            // Haptics are optional and must never affect the game result.
        }
    }
}
#endif

#if canImport(AVFoundation) && os(iOS)
import AVFoundation

@available(iOS 13.0, *)
public final class SystemAudioClient: AudioClient, @unchecked Sendable {
    private let bundle: Bundle
    private var player: AVAudioPlayer?

    public init(bundle: Bundle = .main) {
        self.bundle = bundle
    }

    public func playFlip() async {
        play(resource: "flip")
    }

    public func playResult() async {
        play(resource: "result")
    }

    public func playRareResult() async {
        play(resource: "rare-result")
    }

    public func stop() async {
        player?.stop()
        player = nil
    }

    private func play(resource: String) {
        guard let url = bundle.url(forResource: resource, withExtension: "wav") else { return }

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
            player?.play()
        } catch {
            player = nil
        }
    }
}
#endif

#if canImport(CoreMotion) && os(iOS)
import CoreMotion

@available(iOS 13.0, *)
public final class SystemMotionClient: MotionClient, @unchecked Sendable {
    private let manager = CMMotionManager()
    private var continuation: AsyncStream<Void>.Continuation?
    private var lastShake = Date.distantPast
    private let cooldown: TimeInterval

    public init(cooldown: TimeInterval = 0.8) {
        self.cooldown = cooldown
    }

    public func shakeEvents() -> AsyncStream<Void> {
        AsyncStream { continuation in
            self.continuation = continuation
            continuation.onTermination = { [weak self] _ in
                Task { await self?.stop() }
            }
        }
    }

    public func start() async {
        guard manager.isAccelerometerAvailable else { return }

        manager.accelerometerUpdateInterval = 0.1
        manager.startAccelerometerUpdates(to: OperationQueue()) { [weak self] data, _ in
            guard let self, let acceleration = data?.acceleration else { return }
            let magnitude = sqrt(
                acceleration.x * acceleration.x
                    + acceleration.y * acceleration.y
                    + acceleration.z * acceleration.z
            )

            guard magnitude > 2.2 else { return }
            let now = Date()
            guard now.timeIntervalSince(self.lastShake) >= self.cooldown else { return }
            self.lastShake = now
            self.continuation?.yield()
        }
    }

    public func stop() async {
        manager.stopAccelerometerUpdates()
        continuation?.finish()
        continuation = nil
    }
}
#endif

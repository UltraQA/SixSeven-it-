import SixSevenCore

#if canImport(CoreHaptics) && os(iOS)
import CoreHaptics

@available(iOS 17.0, *)
actor SystemHapticsClient: HapticsClient {
    private var engine: CHHapticEngine?

    func prepare() async { ensureEngine() }

    func playLaunch() async { play(intensity: 0.45, sharpness: 0.55) }

    func playResult() async { play(intensity: 0.7, sharpness: 0.6) }

    func playRareResult() async { play(intensity: 1.0, sharpness: 0.8) }

    func stop() async {
        try? await engine?.stop()
        engine = nil
    }

    private func ensureEngine() {
        guard engine == nil, CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        do {
            let newEngine = try CHHapticEngine()
            newEngine.resetHandler = { [weak self] in
                Task { await self?.handleEngineReset() }
            }
            try newEngine.start()
            engine = newEngine
        } catch {
            engine = nil
        }
    }

    private func handleEngineReset() {
        engine = nil
        ensureEngine()
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

@available(iOS 17.0, *)
actor SystemAudioClient: AudioClient {
    private let bundle: Bundle
    private var player: AVAudioPlayer?

    init(bundle: Bundle = .main) {
        self.bundle = bundle
    }

    func playFlip() async { play(resource: "flip") }

    func playResult() async { play(resource: "result") }

    func playRareResult() async { play(resource: "rare-result") }

    func stop() async {
        player?.stop()
        player = nil
    }

    private func play(resource: String) {
        guard let url = bundle.url(forResource: resource, withExtension: "wav") else { return }

        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true, options: [.notifyOthersOnDeactivation])
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

@available(iOS 17.0, *)
actor SystemMotionClient: MotionClient {
    private let manager = CMMotionManager()
    private var continuation: AsyncStream<Void>.Continuation?
    private var lastShake = Date.distantPast
    private let cooldown: TimeInterval

    init(cooldown: TimeInterval = 0.8) {
        self.cooldown = cooldown
    }

    nonisolated func shakeEvents() -> AsyncStream<Void> {
        AsyncStream { continuation in
            Task { await self.install(continuation: continuation) }
        }
    }

    private func install(continuation: AsyncStream<Void>.Continuation) {
        self.continuation = continuation
        continuation.onTermination = { [weak self] _ in
            Task { await self?.stop() }
        }
    }

    func start() async {
        guard manager.isAccelerometerAvailable else { return }

        manager.accelerometerUpdateInterval = 0.1
        manager.startAccelerometerUpdates(to: OperationQueue()) { [weak self] data, _ in
            guard let acceleration = data?.acceleration else { return }
            let magnitude = sqrt(
                acceleration.x * acceleration.x
                    + acceleration.y * acceleration.y
                    + acceleration.z * acceleration.z
            )
            guard magnitude > 2.2 else { return }
            Task { await self?.handleShake() }
        }
    }

    private func handleShake() {
        let now = Date()
        guard now.timeIntervalSince(lastShake) >= cooldown else { return }
        lastShake = now
        continuation?.yield()
    }

    func stop() async {
        manager.stopAccelerometerUpdates()
        continuation?.finish()
        continuation = nil
    }
}
#endif

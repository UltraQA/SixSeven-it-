# SixSeven it! — Architecture

## 1. Цели и вариант

MVP строится на feature-oriented MVVM с чистым domain layer. TCA не вводится заранее: состояние мало. При росте side effects state machine можно мигрировать в TCA без изменения доменных протоколов.

Слои: Domain (модели, rules, use cases); Application (ViewModel/orchestration); Infrastructure (RNG, storage, motion, haptics, audio, share); Presentation (SwiftUI); Rendering (SwiftUI и RealityKit adapters).

## 2. Domain

`@code
enum Outcome: String, Codable, CaseIterable, Sendable {
    case six = "6"
    case seven = "7"
    case sixtySeven = "67"
}

struct GameRules: Equatable, Sendable {
    let sixProbability = 0.475
    let sevenProbability = 0.475
    let sixtySevenProbability = 0.05
}

struct FlipResult: Equatable, Codable, Sendable {
    let outcome: Outcome
    let question: String?
    let date: Date
}
`@

`GameRules` валидирует сумму; для mapping предпочтителен integer basis `0...9999`. UI не содержит magic numbers.

## 3. RNG и state

`@code
protocol RandomNumberGenerating: Sendable {
    mutating func nextInt(in range: ClosedRange<Int>) -> Int
}

protocol FlipOutcomeProviding: Sendable {
    func makeOutcome() -> Outcome
}
`@

Production adapter скрывает `SystemRandomNumberGenerator`. Tests используют `SequenceOutcomeProvider` или seeded provider. Outcome нельзя выбирать по углу вращения и нельзя вызывать RNG из View.

`@code
enum GamePhase: Equatable, Sendable {
    case idle
    case flipping
    case result(FlipResult)
}

struct GameState: Equatable, Sendable {
    var phase: GamePhase = .idle
    var question = ""
    var statistics = Statistics.empty
}
`@

Переходы: `idle → flipping → result → idle` и `result → flipping`. Concurrent `flipping → flipping` запрещён. `HomeViewModel` — `MainActor`; View отправляет intents, но не реализует business logic.

## 4. SwiftUI и rendering

Компоненты: `HomeView`, `HomeViewModel`, `CoinView`, `QuestionInput`, `FlipButton`, `OutcomeView`, `StatsView`, `SettingsView`, `ShareSheet`, `SixSevenDesignSystem`. Localized strings идут через `Localizable.strings`/typed wrapper.

MVP renderer: `SwiftUICoinRenderer` на `Canvas`/`Shape`/explicit animations. Он получает `CoinAnimationState` и `Outcome`, но не знает probabilities и persistence.

RealityKit изолирован:

`@code
protocol CoinRendering: AnyObject {
    func playFlip(to outcome: Outcome) async throws
}
`@

RealityKit становится обязательным только после визуальной проверки ценности 3D.

## 5. System services

**Core Motion:** `MotionClient` публикует semantic `shakeDetected` через `AsyncStream` или adapter. Нужны toggle, debounce, cooldown и hardware check.

**Core Haptics:** `HapticsClient` предоставляет `prepare`, `playLaunch`, `playResult`, `playRareResult` и `stop`. Ошибки не меняют outcome.

**AVFoundation:** `AudioClient` управляет session и effects; missing file/session → no-op.

**Persistence:** MVP — `UserDefaultsStatisticsStore` с Codable snapshot или actor wrapper. При большой history — SwiftData. Вопросы не сохранять без privacy-решения.

`@code
protocol StatisticsStore: Sendable {
    func load() async throws -> Statistics
    func save(_ statistics: Statistics) async throws
}
`@

## 6. Concurrency

`GameViewModel` — `MainActor`; adapters — `actor` или `Sendable` value types; animation task отменяется при lifecycle change; subscriptions не живут после ухода feature; retain cycles запрещены.

## 7. Design system mapping

Color tokens: `backgroundPrimary`, `backgroundSecondary`, `contentPrimary`, `contentSecondary`, `accentSix`, `accentSeven`, `accentRare`, `surfaceElevated`, `separator`, `destructive`. Нужны Light/Dark и contrast.

Typography: `hero` → rounded black 72pt; `display` → `.largeTitle.bold()`; `title` → `.title2.weight(.semibold)`; `body` → `.body`; `caption` → `.caption`. Поддержать Dynamic Type.

Spacing: `4, 8, 12, 16, 24, 32, 48`. Radius: 8 controls, 16 cards, 24+ hero. Touch target ≥ 44×44pt.

## 8. Project structure

`@text
SixSeven/
├── App/ (SixSevenApp.swift, AppDependencies.swift)
├── Domain/ (Outcome, GameRules, GameState, Statistics, UseCases)
├── Application/ (HomeViewModel.swift)
├── Infrastructure/ (RNG, Persistence, Motion, Haptics, Audio, Sharing)
├── Presentation/ (Home, Stats, Settings, Components)
├── Rendering/ (SwiftUICoinRenderer, RealityKitCoinRenderer)
├── DesignSystem/ (Colors, Typography, Spacing, Components)
└── SixSevenTests/
`@

Фактическая текущая раскладка репозитория сохраняет эти границы через Swift Package targets:

- `Sources/SixSevenCore` — domain contracts, state, persistence protocols и no-op system abstractions;
- `Sources/SixSevenUI` — SwiftUI presentation и `HomeViewModel`;
- `Sources/SixSevenApp` — composition root, native platform adapters и development resources;
- `Tests/SixSevenCoreTests` — быстрые package unit tests;
- `Tests/SixSevenAppTests` — native Xcode test target для simulator execution.

Платформенные Core Haptics, AVFoundation и Core Motion adapters изолированы в app target и реализованы как actors. Это оставляет Core portable и не скрывает mutable platform state за `@unchecked Sendable`.

`Statistics.currentStreak` и `bestStreak` означают последовательность одинаковых outcome, а не количество всех завершённых бросков. Последний outcome сохраняется в Codable snapshot, чтобы серия корректно продолжалась после relaunch.

## 9. Testing

Unit: probability boundaries, rules validation, deterministic provider, state transitions, streak/statistics, persistence round-trip, question trimming.

UI: first launch → `Flip it` → result; blocking during flip; share sheet; settings; Dynamic Type/Dark Mode.

Snapshot: `idle`, `flipping`, `six`, `seven`, `sixtySeven`, Light/Dark и large fonts. Framework — открытое решение; выбрать один и зафиксировать dependency.

## 10. Решения и trade-offs

Принято: MVVM + protocols; SwiftUI default; RealityKit behind boundary; local-only; system RNG; UIKit only for bridges.

Открыто: SwiftData vs UserDefaults после history; SPM modules; TCA при росте; обязательность RealityKit; snapshot dependency; analytics stack.

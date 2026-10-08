# AGENTS.md — SixSeven it!

## 1. Роль Codex

Работай как senior iOS engineer, software architect и product designer. Соблюдай `GAME_DESIGN.md` и `ARCHITECTURE.md`. При конфликте зафиксируй его, выбери минимальное безопасное MVP-решение и добавь запись в `Open Decisions`.

## 2. Канонические правила

- Product name: `SixSeven it!` — рабочее имя.
- Tagline: `Can't decide? Sixseven it.`
- Outcomes: `6`, `7`, `67`.
- Probabilities: `47.5%`, `47.5%`, `5%`.
- Outcome выбирается RNG до animation.
- `67` — редкий эмоционально усиленный result.
- MVP offline, без аккаунта и backend.
- UI strings и technical identifiers — English; документация — Russian.

Нельзя незаметно менять outcome, probabilities, persistence policy или обязательный stack. Такие изменения требуют правки GDD, ARCHITECTURE и tests.

## 3. Ограничения

- SwiftUI — основной UI; UIKit только для bridges.
- RealityKit — изолированный renderer prototype.
- Core Motion, Core Haptics и AVFoundation — optional/degradable.
- Бизнес-логика не находится во View.
- Не использовать singleton для RNG, storage или feature state.
- Не использовать magic numbers для probabilities, timing, spacing и colors.
- Не добавлять network, accounts, ads, purchases без отдельного решения.
- Не хранить user question в cloud.
- Не использовать copyrighted meme audio без лицензии.
- Предпочитать async/await, value types, DI и `Sendable`.
- Не допускать force unwrap там, где возможна безопасная обработка ошибки.

## 4. Milestone workflow

### Milestone 0 — Product baseline

Проверить outcome rules, open decisions, deployment target, screen flow и tokens. Результат — обновлённые docs и implementation plan.

### Milestone 1 — Domain core

Реализовать `Outcome`, `GameRules`, `FlipResult`, `Statistics`, RNG abstraction и state transitions.

Exit criteria: domain не импортирует UI frameworks; boundary tests зелёные; probability mapping deterministic и не зависит от floating-point equality.

### Milestone 2 — SwiftUI MVP

Реализовать `HomeView`, `HomeViewModel`, question input, coin renderer, result state и `Flip again`.

Exit criteria: concurrent flip невозможен; View не решает outcome и не пишет storage напрямую; empty question работает.

### Milestone 3 — System integrations

Добавить motion, haptics, audio, persistence и share через protocols/adapters.

Exit criteria: no-op/failure-safe path для каждого adapter; приложение работает без motion/haptics/audio; данные восстанавливаются после relaunch.

### Milestone 4 — Accessibility and polish

Проверить Dynamic Type, VoiceOver, Reduce Motion, Dark Mode, touch targets, contrast и поддерживаемые orientation.

### Milestone 5 — Release readiness

Проверить performance, cold launch, memory, tests, signing и App Store copy. Exit criteria: tests зелёные, нет P0/P1, docs обновлены, создан atomic Conventional Commit.

## 5. Обязательные tests

- outcome boundary mapping для `0...9999`;
- сумма probabilities = 1;
- deterministic coverage для `6`, `7`, `67`;
- state machine запрещает concurrent flip;
- `67` обновляет rare count и special streak;
- persistence round-trip;
- UI flow `Flip it` → result → `Share result`;
- snapshots result states, Dark Mode и Dynamic Type.

Не использовать sleep для flaky integrations: применять test doubles, bounded timeout и cancellation.

## 6. Code review checklist

Проверить минимальный public API, initializer-based DI, отсутствие retain cycles, корректные actor isolation/Sendable, понятный error handling, localization, accessibility, Swift API Design Guidelines и обновление docs при изменении контракта.

## 7. Definition of Done

Код компилируется на target deployment, tests проходят, happy path проверен на simulator/device, optional capabilities не ломают MVP, docs/open decisions обновлены, в diff нет debug logs/секретов/temporary files, commit соответствует Conventional Commits.

## 8. Commit policy

Английский Conventional Commit, imperative present tense, summary ≤72 символов, без точки:

- `feat(ui): add coin flip home screen`
- `feat(core): implement weighted outcome provider`
- `test(core): cover outcome probability boundaries`
- `fix(persistence): restore statistics on launch`
- `refactor(architecture): isolate motion client`
- `docs(core): document MVP outcome rules`

Один commit — одно логически завершённое изменение. Breaking change требует `!` и body с `BREAKING CHANGE:`.

## 9. Решения и open decisions

Для нового варианта использовать: `Decision`, `Context`, `Trade-offs`, `Open Decision`. Не выдавать допущение за утверждённый факт; для спорного выбора предлагать 2–3 варианта и рекомендовать один.

Текущие open decisions: финальное название (`SixSeven it!` или `6 or 7?`); обязательность RealityKit; история вопросов и privacy; UserDefaults vs SwiftData; snapshot dependency; analytics; финальная palette, coin art и audio assets.

До подтверждения использовать MVP-варианты из GDD и ARCHITECTURE и не расширять scope самостоятельно.

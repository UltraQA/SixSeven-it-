# SixSeven it!

`SixSeven it!` is an offline iOS casual decision game inspired by the Six Seven meme.

The MVP lets a user ask an optional question, flip a coin, and receive one of three outcomes:

- `6` — 47.5%
- `7` — 47.5%
- `67` — 5% rare result

## Project direction

- SwiftUI-first interface with feature-oriented MVVM
- Clean domain layer with dependency-injected, testable game rules
- Local-only MVP without accounts or backend
- Optional haptics, sound, motion control, and RealityKit rendering behind protocols
- UI strings and technical identifiers in English; project documentation in Russian

See [GAME_DESIGN.md](GAME_DESIGN.md) for the product specification, [ARCHITECTURE.md](ARCHITECTURE.md) for the technical design, and [DESIGN_SYSTEM.md](DESIGN_SYSTEM.md) for the visual tokens and screen layouts. Repository workflow and engineering constraints are documented in [AGENTS.md](AGENTS.md).

## CI

GitHub Actions currently runs deterministic SwiftPM tests for pushes and pull requests targeting `main`. Native iOS build, unit tests, and UI tests remain available for local Xcode/Simulator runs but are temporarily excluded from the required CI gate because the hosted Xcode runner is returning exit code 65 before exposing actionable diagnostics. This keeps CI focused on deterministic domain checks while the MVP is being developed.

## Status

MVP implementation is in progress. The current build includes the core game loop, local statistics, settings, native feedback adapters, accessibility tokens, a native Xcode app target, and native unit-test coverage. SwiftPM currently reports 23 passing tests; the iOS scheme also runs `SixSevenAppTests` on the simulator.

## Development assets

The app currently includes short generated WAV placeholders for local development. They are intentionally temporary and should be replaced with licensed final audio without changing resource names. `coin-placeholder.svg` is a temporary visual reference; the MVP coin is rendered natively in SwiftUI. `Assets.xcassets` contains a development AppIcon placeholder and must be replaced with final branded icon assets before App Store submission.

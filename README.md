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

See [GAME_DESIGN.md](GAME_DESIGN.md) for the product specification and [ARCHITECTURE.md](ARCHITECTURE.md) for the technical design. Repository workflow and engineering constraints are documented in [AGENTS.md](AGENTS.md).

## CI

GitHub Actions runs SwiftPM tests and the native iOS simulator test scheme for pushes and pull requests targeting `main`. Failed Xcode test results are uploaded as a workflow artifact when available.

## Status

MVP implementation is in progress. The current build includes the core game loop, local statistics, settings, native feedback adapters, accessibility tokens, a native Xcode app target, and native unit-test coverage. SwiftPM currently reports 21 passing tests; the iOS scheme also runs `SixSevenAppTests` on the simulator.

## Development assets

The app currently includes short generated WAV placeholders for local development. They are intentionally temporary and should be replaced with licensed final audio without changing resource names. `coin-placeholder.svg` is a temporary visual reference; the MVP coin is rendered natively in SwiftUI. `Assets.xcassets` contains a development AppIcon placeholder and must be replaced with final branded icon assets before App Store submission.

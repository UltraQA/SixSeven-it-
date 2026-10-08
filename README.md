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

## Status

Pre-production. The next milestone is the domain core: outcome rules, RNG abstraction, game state transitions, statistics, and unit tests.

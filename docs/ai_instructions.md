# AI Instructions — Incremental Game Project

## Purpose
This file defines how the AI (Codex / ChatGPT / Cursor) should behave when working on this repository.
This is a **game-first project**, not a framework or architecture exercise.

The AI’s primary responsibility is to **express addictive gameplay**, not to maximize abstraction, reuse, or technical purity.

---

## Document Priority Order (Very Important)
When making decisions, follow this order strictly:

1. **DESIGN.md** — Authoritative source of game vision, player psychology, phases, and hooks.
2. **PLAN_GAMEPLAY.md** — What gameplay systems and phases to implement next.
3. **PLAN.md** — Engineering constraints, TDD strategy, and safety rails.

If there is a conflict:
- DESIGN.md wins over everything.
- PLAN_GAMEPLAY.md wins over PLAN.md for *what* to build.
- PLAN.md wins for *how* to build safely.

---

## Core Philosophy
- This is an **incremental game**, not an idle game.
- Player interaction is central; taps/actions must feel meaningful.
- The game should feel *slightly unpredictable but never unfair*.
- Confusion in the short term is acceptable.
- Long-term progress must always trend upward.

> If the system feels strange but compelling, you are probably on the right path.

---

## Gameplay-First Rules
- Do **not** add systems unless they express a gameplay idea from DESIGN.md.
- Do **not** build general-purpose architecture “just in case.”
- Prefer visible player progress over internal correctness.
- Favor behavioral upgrades over numeric-only upgrades.
- Phases of play (gather → upgrade → display/deliver) must remain clear and use distinct screens.

---

## Controlled Chaos Rules
The game may include:
- Hidden internal state
- Threshold-based behavior changes
- Delayed or burst rewards
- History-dependent outcomes
- Chance-based outcomes with guardrails (weighted rolls, pity timers)

The game may **not** include:
- Unbounded RNG without safeguards
- Player-visible penalties that permanently reduce progress

Outcomes should be reproducible when seeded or simulated deterministically.

---

## Engineering Guardrails
- Keep SwiftUI dumb.
- Keep game logic deterministic and testable.
- Prefer small, incremental changes (1–3 files per milestone).
- Add tests where logic or rules change.
- Do not refactor unrelated code.

---

## What to Avoid
- Over-generalized engines
- ECS-style abstractions
- Premature persistence layers
- Plugin-style extensibility
- Large refactors without gameplay impact

If you are adding code but the game does not *feel* more interesting, stop.

---

## Milestone Discipline
- Implement **one milestone at a time**.
- After completing a milestone:
  - Stop
  - Summarize what was added
  - Ask for human approval before continuing

Do not chain milestones together without confirmation.

---

## Final Heuristic (Use This)
Before writing code, ask:

> “Does this make the player want to tap one more time?”

If the answer is unclear, pause and ask for guidance.

---

End of instructions.

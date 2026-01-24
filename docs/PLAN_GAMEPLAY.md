# Incremental Prototype Plan (Gameplay-Driven)

> Companion doc: **DESIGN.md** (authoritative for gameplay goals, phases, and hooks).

## Product vision (5–10 bullets)
- Deliver a short, satisfying interactive incremental loop inspired by Digseum/Gnorp-style play.
- Emphasize active input (taps/gestures) over idle gains; progress comes from engagement.
- Keep UI minimal: a primary action, clear resource display, and a focused upgrade list. Use separate phase screens rather than over-clutter a single screen.
- Ensure the game has **distinct phases** of play (break/gather → refine/upgrade → deliver/display).
- Implement “controlled chaos”: outcomes can feel surprising with **chance elements** while staying testable.
- Upgrades should primarily change **behavior**, not just add +N.
- Maintain deterministic, testable core logic separate from SwiftUI.
- Enable easy iteration on balancing via data-driven structs/enums.

## Core loop + progression loop
- **Core loop (seconds):** Player performs a primary action (tap) to gain a base resource.
- **Progression loop (minutes):** Spend resources on upgrades that change behavior and unlock phases.
- **Phase loop (meta):** Completing deliveries/displays unlocks a new tier/layer back in Phase 0.

## Systems/components breakdown
- **State model:** `GameState` (visible resources, upgrade levels, phase, unlocks).
- **Hidden state:** `HiddenState` (pressure/stress/etc.), internal only.
- **Economy:** Deterministic cost/benefit calculations for upgrades and conversions.
- **Phases:** A small `Phase` enum driving what the main button does.
- **Upgrades:** Tiered upgrades with scaling costs and behavior modifiers.
- **Actions:** Player-triggered actions defined by current phase with chance-based bonuses.
- **UI views:**
  - Dedicated phase screens (phase label + main action + resource display)
  - Upgrade list view (disabled state when unaffordable/locked)
  - Artifact/progression track (e.g., displays/cargo/castle tier)
  - Gathering mini-game surface (timing/pattern/streak) in the gather phase screen

## TDD strategy (gameplay-first)
- Unit tests for engine logic:
  - Phase transitions (unlock thresholds)
  - Deterministic chaos pattern(s)
  - Conversion rules (Ore → Parts → Displays)
  - Long-run monotonic growth (e.g., 500 taps doesn’t decrease totals)
- Minimal UI tests after engine behaviors exist.

## Milestones (small steps, 1–3 files max)
1. [x] **Project scaffold + test target**
2. [x] **Core engine model (tests first)**
3. [x] **Upgrade system (tests first)**
4. [x] **Unlocks/soft gating (tests first)**
5. [x] **SwiftUI binding layer**
6. [x] **Upgrade UI list**
7. [ ] **Phases MVP (tests first)**
   - Add `Phase` enum and route behavior by phase.
   - Minimal UI: dedicated screens per phase with phase label + action changes.
8. [ ] **Add resources + conversions (tests first)**
   - Implement `Ore → Parts` conversion in Phase 1.
   - Implement `Parts → Displays` progress in Phase 2.
9. [ ] **Controlled chaos pattern (tests first)**
   - Implement threshold snap OR delayed payout.
   - Add long-run monotonic growth test.
10. [ ] **Behavioral upgrades (tests first)**
   - Add 3 upgrades: one for breaking behavior, one for conversion, one for meta progression.
11. [ ] **Balancing pass (light)**
   - Tune thresholds so Phase 1 happens within ~60s and Phase 2 within ~3–5 min.

## Approval gates
After each milestone step, stop and request approval before continuing.

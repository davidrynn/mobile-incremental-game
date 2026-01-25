# Incremental Prototype Plan

## Product vision (5–10 bullets)
- Deliver a short, satisfying interactive incremental loop inspired by Digseum/Gnorp-style play.
- Emphasize active input (taps/gestures) over idle gains; progress comes from engagement.
- Provide quick feedback (numbers go up, sounds/haptics-ready hooks) without clutter.
- Add a compact upgrade system that changes how actions feel and scale.
- Introduce soft gating to pace discovery (unlock new actions/tiers after milestones).
- Keep UI minimal: a primary action, clear resource display, and a focused upgrade list, split across dedicated phase screens.
- Maintain deterministic, testable core logic separate from SwiftUI, with chance elements guarded and reproducible when seeded.
- Enable easy iteration on balancing via data-driven structs/enums.
- Prepare for persistence later without implementing it now.

## Core loop + progression loop
- **Core loop (seconds):** Player performs a primary action (tap/press) to gain a base resource.
- **Progression loop (minutes):** Spend resource on upgrades that:
  - Increase yield per action.
  - Unlock new actions (shorter loops or higher risk/reward).
  - Introduce a secondary resource or multiplier after a threshold.
- **Soft gating:** Upgrades unlock after reaching specific milestones (resource totals or upgrade levels).

## Systems/components breakdown
- **State model:** `GameState` value type with resource counts, upgrade levels, and unlocked actions.
- **Economy:** Deterministic cost/benefit calculations for upgrades and actions.
- **Upgrades:** Tiered upgrades with scaling costs and effects.
- **Actions:** Player-triggered actions with defined yields and optional cooldowns.
- **Timers (if any):** Optional short cooldowns for special actions (but no idle gain).
- **Persistence:** Placeholder protocol/abstraction, in-memory only for now.
- **UI views:**
  - Dedicated phase screens (primary action + resource display per phase).
  - Upgrade list view (disabled state when unaffordable/locked).
  - Progression summary (milestones/unlocks).
- **Visual elements:**
  - Primary action feedback (press state, glow, or bounce).
  - Ambient backdrop tied to progression phase.
  - Minimal progress indicators (milestones, streaks, or meters).
  - Micro-animations on resource gain.

## Data model approach
- Use structs/enums for all game definitions (e.g., `ActionType`, `UpgradeType`).
- `GameState` as a pure value type; reducers/functions apply player inputs to state.
- Deterministic simulation step:
  - `apply(action:to:)` and `purchase(upgrade:in:)` functions.
  - Chance-based outcomes are allowed with guardrails and seeded reproducibility.
- Separation of concerns:
  - Core logic in a `GameEngine` module (or folder) with no SwiftUI dependencies.
  - SwiftUI binds to observable wrapper that delegates to the engine.

## TDD strategy
- **Test layers:**
  - Unit tests for engine logic (resource gains, upgrade costs, unlocks).
  - Unit tests for state transitions (actions and purchases).
  - Minimal UI tests only after engine is stable.
- **What to test first:**
  - Base action yield.
  - Upgrade purchase affordability and effects.
  - Unlock thresholds for new actions/upgrades.
- **Deterministic simulation testing:**
  - Given initial `GameState`, applying action or purchase yields expected state.
  - Ensure costs/benefits match formula across multiple levels.

## Milestones (small steps, 1–3 files max)
1. [x] **Project scaffold + test target**
   - Create SwiftUI app project and Swift Testing target.
   - Acceptance: project builds and tests run.
2. [x] **Core engine model (tests first)**
   - Add `GameState`, `ActionType`, and `apply(action:)` with tests.
   - Acceptance: tests cover base action yield and state updates.
3. [x] **Upgrade system (tests first)**
   - Add `UpgradeType`, cost/effect formulas, purchase logic.
   - Acceptance: tests for affordability, cost scaling, and effect application.
4. [x] **Unlocks/soft gating (tests first)**
   - Add unlock thresholds for actions/upgrades.
   - Acceptance: tests for locked/unlocked state transitions.
5. [x] **SwiftUI binding layer**
   - Observable wrapper around engine, basic UI: action button + resource display.
   - Acceptance: app runs, action updates resource on tap.
6. [x] **Upgrade UI list**
   - List of upgrades with affordability/locked states.
   - Acceptance: purchasing upgrades updates state and UI.
7. [x] **Phase progression + conversions**
   - Add Phase enum and routing for gather/refine/deliver.
   - Implement Ore → Parts and Parts → Displays conversions.
   - Add phase unlock thresholds.
8. [x] **Hidden state + controlled chaos**
   - Add pressure release cycles and cadence streak bonuses.
   - Add targeted tests for pressure release and cadence behavior.
9. [x] **Behavioral upgrades**
   - Add upgrades that modify tap yield, pressure release, and conversions.
10. [ ] **Visual elements pass**
   - Add minimal progress indicator to main view.
   - Add button feedback (scale/glow/press).
   - Add subtle background/ambient shift tied to progression.
   - Phase dashboard already includes cadence/pressure indicators and a gradient background; button feedback still needed.

## Acceptance criteria per milestone
- [x] **M1:** Xcode project builds, tests pass.
- [x] **M2:** Engine tests for base action pass, no SwiftUI dependencies.
- [x] **M3:** Upgrade tests pass with deterministic cost/effect.
- [x] **M4:** Unlock tests pass, gating works as specified.
- [x] **M5:** Tapping updates resources in UI.
- [x] **M6:** Upgrades visible, purchasable, and gated in UI.

## Approval gates
After each milestone step, stop and request approval before continuing.

## Next steps (post-M6)
- Add persistence layer (AppStorage or file-based) and migration strategy.
- Expand upgrade variety (multipliers, action unlocks with cooldowns).
- Add balancing pass for economy scaling and pacing.
- Introduce lightweight feedback (haptics + SFX hooks) with toggle.
- Add analytics hooks for session length and upgrade usage.

# Incremental Prototype Plan (Expanded – Controlled Chaos Edition)

## Product vision (expanded)
- Deliver a short, satisfying **active incremental** loop inspired by Digseum/Gnorp-style play.
- Keep the surface interaction extremely small (initially one main action per phase screen, one upgrade).
- Allow progression to *feel* mysterious, emergent, or chaotic while remaining deterministic and testable.
- Embrace strange outcomes as long as progress trends upward over time.
- Favor upgrades that change **how progress behaves**, not just how fast numbers increase.
- Preserve a strong separation between engine logic and SwiftUI.
- Maintain a tiny visible UI while allowing large internal state growth, with **separate phase screens** for clarity.
- Optimize for discovery, surprise, and “why did that just happen?” moments.
- Document prioritize order - ai_instructions, DESIGN, PLAN_GAMEPLAY, PLAN

---

## Core fantasy
The player is not simply incrementing a number — they are **applying force to a resistant system**.
Progress is the *result* of pressure, stress, instability, or other abstract forces resolving.

This supports inspiration from Space Rock Breaker–style progression without simulating real physics.

---

## Core loop (seconds)
- Player taps the primary button.
- A **force/action** is applied to the system.
- Visible resources increase as a *result* of hidden state resolution.
- Gathering should include a lightweight mini-game (timing, pattern, or streak) that introduces chance-based rewards.

> Important: the visible increment does **not** need to map 1:1 to taps.

---

## Progression loop (minutes)
- Spend visible resources on upgrades.
- Upgrades modify:
  - How taps are interpreted
  - How hidden variables interact
  - When and how stored value is released
- New behaviors unlock through milestones, not UI complexity.

---

## Hidden state system (new)
Introduce internal-only variables that influence output but are not shown to the player.

Examples (choose a small subset):
- Pressure
- Stress
- Heat
- Instability
- Charge
- Entropy

Rules:
- Hidden state is deterministic.
- Hidden state is mutated by actions and upgrades.
- Hidden state indirectly affects visible gains.

---

## “Fake algorithm” patterns (intentional)
The engine may *appear* non-algorithmic while remaining fully testable.

Allowed behaviors:
- Threshold snapping (sudden jumps after invisible limits)
- Delayed payout (stored value released in bursts)
- Elastic resistance (diminishing returns that later invert)
- State cycling (formulas rotate every N actions)
- History-dependent output (recent behavior matters)

Design rule:
> If two systems interact in a surprising way but long-term progress remains positive, keep it.

---

## Upgrade philosophy (expanded)
Upgrades should primarily:
- Change relationships between variables
- Alter resolution timing
- Re-route excess values
- Flip or bend scaling rules

Avoid upgrades that are *only* flat +N unless they serve onboarding.

---

## Phases (explicit screens)
Phases should be explicit with their **own screens** and separated mechanics:

- Phase 0: Linear, understandable growth
- Phase 1: Bursts and stalls
- Phase 2: Unpredictable but accelerating gains
- Phase 3: Player intuition replaces clarity

Phases emerge from upgrades, but should be represented with dedicated screens.

---

## Systems/components breakdown
- **GameState** (visible):
  - Resources
  - Purchased upgrades
  - Unlock milestones

- **HiddenState** (internal):
  - Abstract variables (pressure, stress, etc.)
  - No direct UI exposure

- **GameEngine**:
  - Pure functions
  - Deterministic state transitions
  - Applies actions and upgrades
  - Per-phase logic separated into dedicated modules/reducers

- **Upgrades**:
  - Modify rules, not just values

- **SwiftUI layer**:
  - Dumb rendering
  - Observes visible state only
- **Visual layer**:
  - Primary action feedback (press states, glow, or bounce)
  - Ambient backdrop tied to progression phase
  - Small progress indicators (milestones, streaks, or charge meters)
  - Optional micro-animations on resource gain
  - Dedicated screens per phase with their own mini-game elements

---

## Data model approach
- All definitions via enums/structs.
- GameState + HiddenState updated together.
- Allow chance-based outcomes with guardrails (e.g., weighted rolls, pity timers).
- Outcomes remain reproducible when seeded or deterministically simulated.

---

## TDD strategy (adjusted)
### Test what matters:
- Progress is monotonic over long runs
- No negative or invalid visible values
- Upgrades apply expected rule changes

### Do NOT test:
- Player-facing predictability
- Short-term pacing feel

---

## Milestones (updated)
1. [x] Project scaffold + test target
2. [x] Core engine model (visible state)
3. [x] Basic upgrade system
4. [x] Unlocks / soft gating
5. [x] SwiftUI binding layer
6. [x] Upgrade UI list
7. [x] **Hidden state introduction**
   - Add HiddenState struct
   - Modify action resolution
8. [x] **Behavioral upgrade**
   - One upgrade that changes progression behavior
9. [x] **Controlled chaos pass**
   - Add cadence sweet-spot bonuses and pressure release cycles
   - Add targeted tests for pressure release and cadence behavior
10. [x] **Visual elements pass**
    - Add a minimal progress indicator
    - Add button feedback (scale/glow/press)
    - Add subtle background/ambient shift tied to progression
    - Phase dashboards now include cadence/pressure indicators and a gradient background; button feedback completed

---

## Acceptance philosophy
- Short-term confusion is acceptable.
- Long-term growth is required.
- Determinism is mandatory.
- Surprise is a feature.

---

## Approval gates
After each milestone, stop and request approval before continuing.

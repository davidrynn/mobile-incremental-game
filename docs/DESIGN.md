# Design Doc — Controlled Chaos Incremental (SwiftUI Prototype)

## North star
A tiny, **active** incremental game where the player *applies force to a resistant system* (rock/asteroid/cargo/structure), unlocking surprising behaviors and **distinct phases of play** that keep the “just one more upgrade” loop alive.

This document exists to keep implementation decisions anchored to **gameplay hooks**, not just architecture.

---

## Core hooks (the “addictive mind”)
These are the behaviors we want the game to repeatedly trigger:

1. **Immediate reward**
   - Every tap produces a clear response (number change + micro-feedback).
2. **Near-term goal tension**
   - “I’m close to the next upgrade / unlock / phase.”
3. **Surprise with perceived chance**
   - “Why did it spike?” (deterministic chaos or controlled RNG).
4. **Meaningful upgrades**
   - Upgrades change *how it feels*, not only the rate.
5. **Phase shifts**
   - The game periodically changes what you’re doing (mine → haul → display), creating novelty while staying simple. Each phase has its own screen.
6. **Visible progression artifact**
   - A thing that grows/accumulates (museum/castle/cargo bay) to make progress feel physical and collectible.
7. **Addictive phase loops**
   - Every phase/mechanic should feel replayable on its own: clear feedback, escalating stakes, and a “just one more try” beat.

---

## Player fantasy & theme options (pick one later)
Keep theme flexible for now; implement mechanics in a theme-agnostic way.

- **Space Rock Breaker vibe:** apply force → fracture → harvest rare bits
- **Digseum vibe:** mine → process → display artifacts in a “museum”
- **Castle growth:** gather → upgrade → visually expand a structure
- **Cargo loop:** mine → haul → drop-off → expand ship/warehouse

> Implementation should support swapping the “artifact display” skin later.

---

## Phases of play (must exist, even if minimal UI)
The game should have at least three phases. Each phase is a *mode* with its **own screen**, and each phase’s mechanic should live in its **own separated logic** (per-phase reducer/engine module).

### Phase 0 — Break / Gather (starts here)
- **Action:** Tap = Apply Force
- **Output:** `Ore` (or `Rubble`)
- **Hidden state:** pressure/stress/instability builds and resolves
- **Chance/gameplay:** a lightweight gathering mini-game (timing window, streak meter, or pattern) with a chance-based bonus outcome (cadence window streaks count)
- **Goal:** first meaningful upgrade + first unlock

### Phase 1 — Upgrade / Process
Unlocked after milestone (e.g., total Ore, or first upgrade).
- **Action:** Tap = Process/Refine (converts `Ore` → `Loot` or `Parts`)
- **Output:** `Parts` (spent on upgrades) + occasional “artifact”
- **Chance/gameplay:** conversion has a chance-based bonus (crit refine, extra artifact shard, etc.)
- **Goal:** upgrade engine + unlock delivery/display

### Phase 2 — Deliver / Display (meta-progression)
Unlocked after milestone (e.g., enough Parts, or a specific upgrade).
- **Action:** Tap = Deliver/Install
- **Output:** increases a **visible artifact**:
  - museum display count
  - ship cargo bay filled
  - castle size tier
- **Chance/gameplay:** delivery can occasionally “overfill” or add a bonus slot
- **Goal:** complete a “set” to unlock new breaking layer / new tier

> Phase switching should use dedicated screens per phase (even if minimal).

---

## Resources (keep minimal, but meaningful)
Visible:
- `Ore` — gained in Phase 0
- `Parts` — gained in Phase 1, spent on upgrades
- `Displays` (or `Cargo` / `CastleTier`) — Phase 2 visible artifact progress

Optional (later):
- `Artifacts` — collectible items that populate the display

Hidden (internal-only):
- `pressure`, `stress`, `heat`, `instability` (choose 2–3)

---

## The one-button interaction model (how it stays simple)
The main button always exists, but its meaning changes by phase:

- Phase 0: **BREAK**
- Phase 1: **REFINE**
- Phase 2: **DELIVER**

This gives novelty without UI bloat.

---

## “Controlled chaos” (chance or deterministic surprise)
We want spikes, stalls, bursts — allow **chance-based outcomes** (especially in gathering) while keeping long-run growth testable.

Allowed deterministic patterns:
- **Threshold snap:** when `pressure` crosses N, next tap yields a burst
- **Delayed payout:** taps bank value; it releases every K taps
- **Elastic resistance:** output falls as you spam; then an upgrade flips it
- **State cycle:** formula rotates every N taps (e.g., 8-step loop)
- **History dependency:** last 5 taps influence the next yield

Design constraint:
- Over long runs (e.g., 500 taps), total progress must increase monotonically.
- Use **chance with guardrails** (e.g., weighted rewards, pity timers) to avoid dead streaks.

---

## Upgrades (must change behavior)
Upgrades should be categorized by *behavior*, not just numbers.

### Category A — Force shaping (Phase 0)
- increases pressure gain per tap
- reduces resistance so bursts happen sooner
- changes burst size vs frequency

### Category B — Conversion shaping (Phase 1)
- improves Ore→Parts conversion rate
- introduces “artifact chance” via a cadence or RNG (e.g., every 25th refine or a small chance per tap)

### Category C — Meta progression (Phase 2)
- increases delivery capacity per tap
- unlocks new display slots / cargo bays / castle wings
- completing sets unlocks a new “rock layer” back in Phase 0

---

## Soft gating & unlocks (make goals obvious)
Unlock triggers should be simple and readable:
- reach X Ore
- buy upgrade Y
- complete Z deliveries
- fill N display slots

Even if the player doesn’t see hidden state, they must always have a visible “next thing”.

---

## Minimal content for MVP (the slice Codex should implement)
This is the smallest version that still feels like a game:

1. Implement **3 phases** with **separate screens** (one main action per screen)
2. Implement **2 visible resources** + **1 visible artifact track**
   - Ore → Parts → Displays
3. Implement **3 upgrades** (one per category)
   - one behavior-changing upgrade is mandatory
4. Implement **one chaos pattern** (threshold snap, delayed payout, or chance-based bonus)
5. Add a **gathering mini-game** (simple timing, streak, or pattern input)
5. Implement a tiny UI:
   - resource counters
   - current phase label
   - main button label changes per phase
   - upgrade list

Acceptance feel:
- Within 60 seconds, player hits Phase 1
- Within 3–5 minutes, player hits Phase 2
- Phase 2 completion loops back to Phase 0 with a new tier/“layer” modifier

---

## What Codex should NOT do
- Don’t add complex architectures, modules, or abstractions “just in case”.
- Don’t add persistence yet (optional later).
- Don’t add excessive RNG without guardrails.

---

## What Codex SHOULD produce each step
For each milestone, Codex should include:
- A short “Gameplay intent” paragraph (what hook this step serves)
- Tests for deterministic behavior (engine-only)
- Minimal UI changes to surface the new gameplay

---

## Suggested file layout (lightweight)
- `Engine/` — pure logic (GameState, HiddenState, reducer)
- `UI/` — SwiftUI views and bindings
- `Tests/` — engine tests

No separate “systems” unless it’s clearly useful.

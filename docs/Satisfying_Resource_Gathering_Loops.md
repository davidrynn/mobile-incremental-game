# Satisfying Resource-Gathering Loops (Low-Stress Action)

This doc captures **why Space Rock Breaker–style pickups feel satisfying** and provides **repeatable action-loop patterns** you can reuse for new mini-games in this project.

---

## Design Goal

Create mini-games that are:

- **Low stress** (mistakes are recoverable, danger is mild)
- **About picking things up** (frequent collection moments)
- **Visually and tactically satisfying** (juice, clustering, snap-to)
- **Easy to extend incrementally** (upgrades change *how collecting feels*)

---

## Why Picking Things Up Feels So Good

### 1) High micro-reward frequency
- The player gets many small “wins” per minute.
- Each pickup becomes a tiny checkpoint of progress.

**Design implication:** Early game should yield a pickup every **1–3 seconds**.

### 2) Predictable effort → predictable payoff (agency)
- Player *chooses* a target, acts, and sees the reward.
- Feels earned, not passive.

**Design implication:** Let the player “cause” drops (shoot, tether, bump, sweep), even if it’s easy.

### 3) Low threat keeps the player in flow
- Slow hazards prevent stress spikes.
- Repetition stays soothing rather than draining.

**Design implication:** Make danger mostly **time loss** or **efficiency loss**, not hard failure.

### 4) Clustering + scooping creates mini-jackpots
- Vacuuming a *bundle* of items feels like a win even if each is small.
- “Scoop moments” are inherently gratifying.

**Design implication:** Design the system to naturally create **clusters** (splits, bursts, drift lanes).

### 5) “Juice” turns math into sensation
- Snap-to magnet arcs, satisfying sounds, tiny haptics, number pops.
- The reward becomes physical.

**Design implication:** Invest in *pickup feedback* more than in complex levels.

### 6) Variable reward without punishment
- Some drops are rarer / higher value, but nothing feels like a penalty.
- This adds excitement without anxiety.

**Design implication:** Add “crit drops” / “bonus fragments” / “lucky streaks” without harsh downside.

### 7) Visible accumulation = identity progression
- Inventory growth, meters filling, upgrades unlocking.
- Player reads it as “I’m becoming stronger.”

**Design implication:** Always show **what increased** and **why it matters** (next upgrade, unlock, multiplier).

---

## Core Recipe to Reuse

Keep these constants across mini-games:

- **Low penalty:** mistakes cost time/efficiency, not the run
- **High pickup cadence:** early pickup every 1–3 seconds
- **Occasional scoop jackpots:** clusters, chain pickups, bursts
- **Strong pickup feedback:** snap-to, pop sounds, subtle haptics, readable VFX
- **Upgrades change feel:** magnet radius, multi-collect, auto-collect, chain, pull strength

---

## Mini-Game Loop Patterns (Gather-Focused, Low-Stress)

Each pattern is designed to work on a simple screen (no maze authoring).

### A) Vacuum / Magnet Harvest (“the scoop loop”)
**Core:** Objects drift in; steering near them makes them **snap** into you.

- **Player action:** steer near pickups; optionally shoot to create more drops
- **Satisfying moment:** items “zip” into your ship, especially in clusters

**Upgrade axes:**
- magnet radius
- pull strength / speed
- chain pickup (one pickup pulls nearby)
- auto-collector drone

**Low-stress knobs:**
- slow hazards; bumping reduces efficiency rather than killing you

---

### B) Gentle Herding (“the corral loop”)
**Core:** You nudge floating scrap/critters into a **collection zone**.

- **Player action:** steer to push/guide items into a pen
- **Satisfying moment:** the pen fills; “deposit” animation triggers payoff

**Upgrade axes:**
- larger pen / multiple pens
- slow-field or lure beacon
- “sticky bumpers” that guide items
- auto-gates that score deposits

**Low-stress knobs:**
- items drift out slowly (recoverable), not instant failure

---

### C) Tether + Reel (“the fishing loop”)
**Core:** Fire a tether at a target, **reel it in**, collect.

- **Player action:** aim + reel timing (still forgiving)
- **Satisfying moment:** the pull-in + capture “clunk” / “snap” moment

**Upgrade axes:**
- multi-hook
- faster reel
- stronger tether (bigger targets)
- “rarity scanner” to prioritize targets

**Low-stress knobs:**
- missed tethers cost time, not health

---

### D) Orbit Miner (“the rhythm loop”)
**Core:** You orbit an asteroid and “shave” resources each pass.

- **Player action:** maintain orbit; choose angle; time boosts
- **Satisfying moment:** repeated harvest streaks + visible depletion

**Upgrade axes:**
- wider harvest arc
- better cutter (more per pass)
- auto-stabilize orbit
- chance to “burst” into fragments

**Low-stress knobs:**
- drift mistakes slow you down rather than ending the run

---

### E) Conveyor Sorting (“the organize loop”)
**Core:** Items slide by; you route them into bins (tap/flick).

- **Player action:** route/merge/sort
- **Satisfying moment:** “clean” sorting streaks; bins filling and cashing out

**Upgrade axes:**
- smart auto-sorter
- bigger bins
- combo multiplier for streaks
- rare “golden item” that boosts a bin

**Low-stress knobs:**
- mis-sorts reduce a streak rather than wiping everything

---

### F) Pop-and-Cascade (“the burst loop”)
**Core:** Break big nodes that split into many pickups.

- **Player action:** tap/shoot big targets
- **Satisfying moment:** one action → many rewards (burst confetti of loot)

**Upgrade axes:**
- more splits
- chain reaction chance
- pickup multiplier on clusters
- AOE burst tool

**Low-stress knobs:**
- targets are slow and forgiving; focus is on payoff, not survival

---

### G) Sweep / Clear (“the completion loop”)
**Core:** Move across the arena collecting everything you touch; fill meters.

- **Player action:** sweeping movement; gentle route planning
- **Satisfying moment:** large area cleared; meter completion + cash-out

**Upgrade axes:**
- wider sweep width
- temporary speed boosts
- auto-path for nearby pickups
- “bonus zones” that spawn clusters

**Low-stress knobs:**
- hazards are soft barriers; avoid = efficiency, not failure

---

## Evaluation Checklist (Use While Iterating)

A candidate mini-game is “on target” if:

- [ ] Player collects something within the first **3 seconds**
- [ ] Pickups happen at least every **1–3 seconds** early
- [ ] There is a **cluster/scoop jackpot** at least every **15–30 seconds**
- [ ] Mistakes cost **time or efficiency**, not hard failure
- [ ] Upgrades change **feel** (radius, chain, speed), not only numbers
- [ ] Feedback is “juicy”: snap + sound + tiny haptic + clear numbers
- [ ] Progress is visible: inventory, meters, unlocks, next goal

---

## Iteration Prompts (Quick Design Questions)

When you create a new mini-game, answer these:

1. **What is the player’s core verb?** (scoop / reel / herd / sweep / burst / sort)
2. **Where does the loot come from?** (break targets / drift spawns / deposits / chain reactions)
3. **What creates clusters naturally?** (bursts, drift lanes, gravity wells, deposits)
4. **What is the soft penalty?** (slowdown, lost streak, reduced multiplier)
5. **What’s the “satisfying moment” animation/sound?** (zip, clunk, pop, cash-out)
6. **What upgrade changes the feel first?** (magnet radius, chain pickup, auto-collector)
7. **What is the 30–60 second goal?** (fill meter, deposit X, reach multiplier Y)

---

## Notes for Space Rock Breaker–Style Feel

- Keep asteroids **slow and readable**
- Ensure drops **float slightly**, so “scooping” has motion
- Add “magnet” *early* so collection is snappy
- Use occasional **bonus rocks** that explode into clusters

---

## Next Step Suggestions (Optional)

- Pick **3 patterns** above and make tiny prototypes (one screen, one minute loop).
- For each prototype, define:
  - the core verb
  - one cluster mechanic
  - 3 early upgrades (feel-changing)
  - 1 “cash-out” moment


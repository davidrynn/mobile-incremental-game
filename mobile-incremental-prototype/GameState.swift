//
//  GameState.swift
//  mobile-incremental-prototype
//
//  Created by OpenAI on 2025-02-14.
//

import Foundation

enum ActionType: Equatable, Hashable {
    case primaryTap
}

enum UpgradeType: Equatable, Hashable, CaseIterable {
    case primaryYield
    case pressureValve
    case refinementCoils
    case displayRig
}

enum Phase: Int, Equatable, CaseIterable {
    case gather = 0
    case refine = 1
    case deliver = 2
}

struct GameState: Equatable, Sendable {
    var ore: Int
    var parts: Int
    var displays: Int
    var totalPartsEarned: Int
    var totalDisplaysEarned: Int
    var primaryYieldLevel: Int
    var pressureValveLevel: Int
    var refinementCoilsLevel: Int
    var displayRigLevel: Int
    var totalOreEarned: Int
    var gatherStreak: Int
    var currentPhase: Phase

    init(
        ore: Int = 0,
        parts: Int = 0,
        displays: Int = 0,
        totalPartsEarned: Int = 0,
        totalDisplaysEarned: Int = 0,
        primaryYieldLevel: Int = 0,
        pressureValveLevel: Int = 0,
        refinementCoilsLevel: Int = 0,
        displayRigLevel: Int = 0,
        totalOreEarned: Int = 0,
        gatherStreak: Int = 0,
        currentPhase: Phase = .gather
    ) {
        self.ore = ore
        self.parts = parts
        self.displays = displays
        self.totalPartsEarned = totalPartsEarned
        self.totalDisplaysEarned = totalDisplaysEarned
        self.primaryYieldLevel = primaryYieldLevel
        self.pressureValveLevel = pressureValveLevel
        self.refinementCoilsLevel = refinementCoilsLevel
        self.displayRigLevel = displayRigLevel
        self.totalOreEarned = totalOreEarned
        self.gatherStreak = gatherStreak
        self.currentPhase = currentPhase
    }
}

struct HiddenState: Equatable, Sendable {
    var pressure: Int
    var cadenceStep: Int

    init(pressure: Int = 0, cadenceStep: Int = 0) {
        self.pressure = pressure
        self.cadenceStep = cadenceStep
    }
}

func phase(for state: GameState) -> Phase {
    if isPhaseUnlocked(.deliver, in: state) {
        return .deliver
    }
    if isPhaseUnlocked(.refine, in: state) {
        return .refine
    }
    return .gather
}

func isPhaseUnlocked(_ phase: Phase, in state: GameState) -> Bool {
    switch phase {
    case .gather:
        return true
    case .refine:
        return state.totalOreEarned >= refinePhaseThreshold
    case .deliver:
        return state.totalPartsEarned >= deliverPhaseThreshold
    }
}

func resolvedPhase(for state: GameState) -> Phase {
    if isPhaseUnlocked(state.currentPhase, in: state) {
        return state.currentPhase
    }
    return phase(for: state)
}

func apply(action: ActionType, to state: GameState, hiddenState: HiddenState) -> (state: GameState, hiddenState: HiddenState) {
    var nextState = state
    var nextHiddenState = hiddenState

    switch action {
    case .primaryTap:
        let currentPhase = resolvedPhase(for: nextState)
        nextState.currentPhase = currentPhase
        let baseYield = 1 + nextState.primaryYieldLevel
        let releaseThreshold = max(1, 4 - nextState.pressureValveLevel)
        let cadenceCycle = 4
        let cadenceSweetSpot = cadenceCycle - 1

        let pressureGain: Int
        let releaseMultiplier: Int
        switch currentPhase {
        case .gather:
            pressureGain = baseYield
            releaseMultiplier = 1
        case .refine:
            pressureGain = max(1, baseYield - 1)
            releaseMultiplier = 2
        case .deliver:
            pressureGain = 1
            releaseMultiplier = 3
        }

        nextHiddenState.pressure += pressureGain
        let release = nextHiddenState.pressure / releaseThreshold
        nextHiddenState.pressure = nextHiddenState.pressure % releaseThreshold

        var cadenceBonus = 0
        if currentPhase == .gather {
            let isSweetSpot = nextHiddenState.cadenceStep == cadenceSweetSpot
            if isSweetSpot {
                nextState.gatherStreak += 1
                cadenceBonus = nextState.gatherStreak
            } else {
                nextState.gatherStreak = 0
            }
            nextHiddenState.cadenceStep = (nextHiddenState.cadenceStep + 1) % cadenceCycle
        } else {
            nextState.gatherStreak = 0
            nextHiddenState.cadenceStep = 0
        }

        let yield = baseYield + (release * releaseMultiplier) + cadenceBonus
        switch currentPhase {
        case .gather:
            nextState.ore += yield
            nextState.totalOreEarned += yield
        case .refine:
            let refinementMultiplier = 1 + nextState.refinementCoilsLevel
            let convertible = min(nextState.ore, yield * refinementMultiplier)
            nextState.ore -= convertible
            nextState.parts += convertible
            nextState.totalPartsEarned += convertible
        case .deliver:
            let displayMultiplier = 1 + nextState.displayRigLevel
            let convertible = min(nextState.parts, yield * displayMultiplier)
            nextState.parts -= convertible
            nextState.displays += convertible
            nextState.totalDisplaysEarned += convertible
        }
    }

    return (nextState, nextHiddenState)
}

func upgradeUnlockThreshold(for upgrade: UpgradeType) -> Int {
    switch upgrade {
    case .primaryYield:
        return 15
    case .pressureValve:
        return 45
    case .refinementCoils:
        return 90
    case .displayRig:
        return 140
    }
}

func isUpgradeUnlocked(_ upgrade: UpgradeType, in state: GameState) -> Bool {
    state.totalOreEarned >= upgradeUnlockThreshold(for: upgrade)
}

func upgradeCost(for upgrade: UpgradeType, atLevel level: Int) -> Int {
    switch upgrade {
    case .primaryYield:
        return 15 * (level + 1)
    case .pressureValve:
        return 30 * (level + 1)
    case .refinementCoils:
        return 50 * (level + 1)
    case .displayRig:
        return 70 * (level + 1)
    }
}

func purchase(upgrade: UpgradeType, in state: GameState, hiddenState: HiddenState) -> (state: GameState, hiddenState: HiddenState) {
    var nextState = state

    switch upgrade {
    case .primaryYield:
        guard isUpgradeUnlocked(upgrade, in: nextState) else {
            return (nextState, hiddenState)
        }
        let cost = upgradeCost(for: upgrade, atLevel: nextState.primaryYieldLevel)
        guard nextState.parts >= cost else {
            return (nextState, hiddenState)
        }

        nextState.parts -= cost
        nextState.primaryYieldLevel += 1
    case .pressureValve:
        guard isUpgradeUnlocked(upgrade, in: nextState) else {
            return (nextState, hiddenState)
        }
        let cost = upgradeCost(for: upgrade, atLevel: nextState.pressureValveLevel)
        guard nextState.parts >= cost else {
            return (nextState, hiddenState)
        }

        nextState.parts -= cost
        nextState.pressureValveLevel += 1
    case .refinementCoils:
        guard isUpgradeUnlocked(upgrade, in: nextState) else {
            return (nextState, hiddenState)
        }
        let cost = upgradeCost(for: upgrade, atLevel: nextState.refinementCoilsLevel)
        guard nextState.parts >= cost else {
            return (nextState, hiddenState)
        }

        nextState.parts -= cost
        nextState.refinementCoilsLevel += 1
    case .displayRig:
        guard isUpgradeUnlocked(upgrade, in: nextState) else {
            return (nextState, hiddenState)
        }
        let cost = upgradeCost(for: upgrade, atLevel: nextState.displayRigLevel)
        guard nextState.parts >= cost else {
            return (nextState, hiddenState)
        }

        nextState.parts -= cost
        nextState.displayRigLevel += 1
    }

    return (nextState, hiddenState)
}

let refinePhaseThreshold = 60
let deliverPhaseThreshold = 40

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
}

struct GameState: Equatable, Sendable {
    var resource: Int
    var primaryYieldLevel: Int
    var totalResourceEarned: Int

    init(resource: Int = 0, primaryYieldLevel: Int = 0, totalResourceEarned: Int = 0) {
        self.resource = resource
        self.primaryYieldLevel = primaryYieldLevel
        self.totalResourceEarned = totalResourceEarned
    }
}

struct HiddenState: Equatable, Sendable {
    var pressure: Int

    init(pressure: Int = 0) {
        self.pressure = pressure
    }
}

func apply(action: ActionType, to state: GameState, hiddenState: HiddenState) -> (state: GameState, hiddenState: HiddenState) {
    var nextState = state
    var nextHiddenState = hiddenState

    switch action {
    case .primaryTap:
        let baseYield = 1 + nextState.primaryYieldLevel
        let releaseThreshold = 4

        nextHiddenState.pressure += baseYield
        let release = nextHiddenState.pressure / releaseThreshold
        nextHiddenState.pressure = nextHiddenState.pressure % releaseThreshold

        let yield = baseYield + release
        nextState.resource += yield
        nextState.totalResourceEarned += yield
    }

    return (nextState, nextHiddenState)
}

func upgradeUnlockThreshold(for upgrade: UpgradeType) -> Int {
    switch upgrade {
    case .primaryYield:
        return 5
    }
}

func isUpgradeUnlocked(_ upgrade: UpgradeType, in state: GameState) -> Bool {
    state.totalResourceEarned >= upgradeUnlockThreshold(for: upgrade)
}

func upgradeCost(for upgrade: UpgradeType, atLevel level: Int) -> Int {
    switch upgrade {
    case .primaryYield:
        return 10 * (level + 1)
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
        guard nextState.resource >= cost else {
            return (nextState, hiddenState)
        }

        nextState.resource -= cost
        nextState.primaryYieldLevel += 1
    }

    return (nextState, hiddenState)
}

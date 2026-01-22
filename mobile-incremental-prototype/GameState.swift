//
//  GameState.swift
//  mobile-incremental-prototype
//
//  Created by OpenAI on 2025-02-14.
//

import Foundation

enum ActionType: Equatable {
    case primaryTap
}

enum UpgradeType: Equatable {
    case primaryYield
}

struct GameState: Equatable {
    var resource: Int
    var primaryYieldLevel: Int
    var totalResourceEarned: Int

    init(resource: Int = 0, primaryYieldLevel: Int = 0, totalResourceEarned: Int = 0) {
        self.resource = resource
        self.primaryYieldLevel = primaryYieldLevel
        self.totalResourceEarned = totalResourceEarned
    }
}

func apply(action: ActionType, to state: GameState) -> GameState {
    var nextState = state

    switch action {
    case .primaryTap:
        let yield = 1 + nextState.primaryYieldLevel
        nextState.resource += yield
        nextState.totalResourceEarned += yield
    }

    return nextState
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

func purchase(upgrade: UpgradeType, in state: GameState) -> GameState {
    var nextState = state

    switch upgrade {
    case .primaryYield:
        guard isUpgradeUnlocked(upgrade, in: nextState) else {
            return nextState
        }
        let cost = upgradeCost(for: upgrade, atLevel: nextState.primaryYieldLevel)
        guard nextState.resource >= cost else {
            return nextState
        }

        nextState.resource -= cost
        nextState.primaryYieldLevel += 1
    }

    return nextState
}

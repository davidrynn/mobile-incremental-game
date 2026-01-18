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

    init(resource: Int = 0, primaryYieldLevel: Int = 0) {
        self.resource = resource
        self.primaryYieldLevel = primaryYieldLevel
    }
}

func apply(action: ActionType, to state: GameState) -> GameState {
    var nextState = state

    switch action {
    case .primaryTap:
        nextState.resource += 1 + nextState.primaryYieldLevel
    }

    return nextState
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
        let cost = upgradeCost(for: upgrade, atLevel: nextState.primaryYieldLevel)
        guard nextState.resource >= cost else {
            return nextState
        }

        nextState.resource -= cost
        nextState.primaryYieldLevel += 1
    }

    return nextState
}

//
//  GameViewModel.swift
//  mobile-incremental-prototype
//
//  Created by OpenAI on 2025-02-14.
//

import Foundation
internal import Combine

@MainActor
final class GameViewModel: ObservableObject {
    @Published private(set) var state: GameState
    private var hiddenState: HiddenState

    init(state: GameState, hiddenState: HiddenState = HiddenState()) {
        self.state = state
        self.hiddenState = hiddenState
    }

    var resourceText: String {
        "Resource: \(state.resource)"
    }

    var totalEarnedText: String {
        "Total earned: \(state.totalResourceEarned)"
    }

    var upgrades: [UpgradeViewState] {
        UpgradeType.allCases.map { upgrade in
            let level: Int
            switch upgrade {
            case .primaryYield:
                level = state.primaryYieldLevel
            }

            let cost = upgradeCost(for: upgrade, atLevel: level)
            let isLocked = !isUpgradeUnlocked(upgrade, in: state)

            return UpgradeViewState(
                id: upgrade,
                title: upgrade.title,
                level: level,
                cost: cost,
                isLocked: isLocked,
                requirementText: isLocked ? "Unlock at \(upgradeUnlockThreshold(for: upgrade)) total earned" : nil,
                canPurchase: !isLocked && state.resource >= cost
            )
        }
    }

    func tapPrimaryAction() {
        let result = apply(action: .primaryTap, to: state, hiddenState: hiddenState)
        state = result.state
        hiddenState = result.hiddenState
    }

    func purchaseUpgrade(_ upgrade: UpgradeType) {
        let result = purchase(upgrade: upgrade, in: state, hiddenState: hiddenState)
        state = result.state
        hiddenState = result.hiddenState
    }
}

struct UpgradeViewState: Identifiable {
    let id: UpgradeType
    let title: String
    let level: Int
    let cost: Int
    let isLocked: Bool
    let requirementText: String?
    let canPurchase: Bool
}

private extension UpgradeType {
    var title: String {
        switch self {
        case .primaryYield:
            return "Primary Yield"
        }
    }
}

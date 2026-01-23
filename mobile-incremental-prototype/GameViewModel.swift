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

    var currentPhase: Phase {
        phase(for: state)
    }

    var phaseText: String {
        switch currentPhase {
        case .gather:
            return "Phase: Break"
        case .refine:
            return "Phase: Refine"
        case .deliver:
            return "Phase: Deliver"
        }
    }

    var actionPrompt: String {
        switch currentPhase {
        case .gather:
            return "Apply force to build pressure"
        case .refine:
            return "Refine the stored pressure"
        case .deliver:
            return "Deliver stabilized output"
        }
    }

    var actionButtonTitle: String {
        switch currentPhase {
        case .gather:
            return "Break"
        case .refine:
            return "Refine"
        case .deliver:
            return "Deliver"
        }
    }

    var upgrades: [UpgradeViewState] {
        UpgradeType.allCases.map { upgrade in
            let level: Int
            switch upgrade {
            case .primaryYield:
                level = state.primaryYieldLevel
            case .pressureValve:
                level = state.pressureValveLevel
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
        case .pressureValve:
            return "Pressure Valve"
        }
    }
}

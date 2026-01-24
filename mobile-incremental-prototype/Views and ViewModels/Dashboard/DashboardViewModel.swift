//
//  DashboardViewModel.swift
//  mobile-incremental-prototype
//
//  Created by OpenAI on 2025-02-14.
//

import Foundation
internal import Combine

@MainActor
final class DashboardViewModel: ObservableObject {
    @Published private(set) var state: GameState
    private var hiddenState: HiddenState

    init(state: GameState, hiddenState: HiddenState) {
        self.state = state
        self.hiddenState = hiddenState
    }

    var resourceText: String {
        "Ore: \(state.ore)"
    }

    var totalEarnedText: String {
        "Total ore: \(state.totalOreEarned)"
    }

    var currentPhase: Phase {
        phase(for: state)
    }

    var isGatherPhase: Bool {
        currentPhase == .gather
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
            case .refinementCoils:
                level = state.refinementCoilsLevel
            case .displayRig:
                level = state.displayRigLevel
            }

            let cost = upgradeCost(for: upgrade, atLevel: level)
            let isLocked = !isUpgradeUnlocked(upgrade, in: state)

            return UpgradeViewState(
                id: upgrade,
                title: upgrade.title,
                level: level,
                cost: cost,
                isLocked: isLocked,
                requirementText: isLocked ? "Unlock at \(upgradeUnlockThreshold(for: upgrade)) total ore" : nil,
                canPurchase: !isLocked && state.parts >= cost
            )
        }
    }

    var pressureProgress: Double {
        guard releaseThreshold > 0 else { return 1 }
        return min(Double(hiddenState.pressure) / Double(releaseThreshold), 1)
    }

    var pressureStatusText: String {
        "Pressure \(hiddenState.pressure)/\(releaseThreshold)"
    }

    var pressureHintText: String {
        let phaseHint: String
        switch currentPhase {
        case .gather:
            phaseHint = "Break ore quickly to prime the release."
        case .refine:
            phaseHint = "Refining converts ore into parts."
        case .deliver:
            phaseHint = "Delivering installs displays from parts."
        }

        if releaseThreshold <= 1 {
            return "\(phaseHint) Pressure releases instantly."
        }
        return "\(phaseHint) Release every \(releaseThreshold) pressure."
    }

    var cadenceProgress: Double {
        let cycle = cadenceCycle
        guard cycle > 0 else { return 1 }
        return min(Double(hiddenState.cadenceStep) / Double(cycle), 1)
    }

    var cadenceStatusText: String {
        "Cadence \(hiddenState.cadenceStep + 1)/\(cadenceCycle)"
    }

    var cadenceHintText: String {
        "Hit the sweet spot to grow a streak bonus."
    }

    var streakText: String {
        "Streak \(state.gatherStreak)"
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

    private var releaseThreshold: Int {
        max(1, 4 - state.pressureValveLevel)
    }

    private var cadenceCycle: Int {
        4
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
        case .refinementCoils:
            return "Refinement Coils"
        case .displayRig:
            return "Display Rig"
        }
    }
}

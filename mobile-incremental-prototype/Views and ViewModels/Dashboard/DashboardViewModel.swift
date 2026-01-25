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
    
    private var baseYield: Int {
        1 + state.primaryYieldLevel
    }

    private var refineMultiplier: Int {
        1 + state.refinementCoilsLevel
    }

    private var deliverMultiplier: Int {
        1 + state.displayRigLevel
    }

    private var releaseRateText: String {
        let threshold = max(1, 4 - state.pressureValveLevel)
        if threshold <= 1 {
            return "Instant"
        }
        return "Every \(threshold)x"
    }
    
    var boosts: [StatCardViewModel] {
        [
            StatCardViewModel(
                title: "Base Yield",
                value: "\(baseYield)",
                icon: "bolt.fill",
                description: "Ore gained per tap and per pressure release.",
                detailLines: [
                    "Increases pressure gain during Break.",
                    "Improves burst size across all phases."
                ]
            ),
            StatCardViewModel(
                title: "Release Rate",
                value: releaseRateText,
                icon: "gauge.with.dots.needle.bottom.50percent",
                description: "How often stored pressure converts to bonus yield.",
                detailLines: [
                    "Higher rate means more frequent bursts.",
                    "Upgraded by Pressure Valves."
                ]
            ),
            StatCardViewModel(
                title: "Refine Boost",
                value: "x\(refineMultiplier)",
                icon: "wand.and.stars.inverse",
                description: "Multiplier on ore-to-parts conversion in Refine.",
                detailLines: [
                    "Each coil level adds +1x.",
                    "Only active during the Refine phase."
                ]
            ),
            StatCardViewModel(
                title: "Deliver Boost",
                value: "x\(deliverMultiplier)",
                icon: "shippingbox.fill",
                description: "Multiplier on parts-to-displays conversion in Deliver.",
                detailLines: [
                    "Each rig level adds +1x.",
                    "Only active during the Deliver phase."
                ]
            )
        ]
    }
    
    var resources: [StatCardViewModel] {
        [
            StatCardViewModel(
                title: "Ore",
                value: "\(state.ore)",
                icon: "mountain.2.fill",
                description: "Raw material earned during Break.",
                detailLines: [
                    "Converted into parts in Refine.",
                    "Spent indirectly through conversions."
                ]
            ),
            StatCardViewModel(
                title: "Parts",
                value: "\(state.parts)",
                icon: "gearshape.2.fill",
                description: "Intermediate goods produced in Refine.",
                detailLines: [
                    "Used to buy upgrades.",
                    "Converted into displays in Deliver."
                ]
            ),
            StatCardViewModel(
                title: "Displays",
                value: "\(state.displays)",
                icon: "photo.on.rectangle.angled",
                description: "Finished output created in Deliver.",
                detailLines: [
                    "Represents installed results.",
                    "Grows with Deliver boosts."
                ]
            ),
            StatCardViewModel(
                title: "Total Ore",
                value: "\(state.totalOreEarned)",
                icon: "chart.line.uptrend.xyaxis",
                description: "Lifetime ore earned across all sessions.",
                detailLines: [
                    "Unlocks new upgrades at thresholds.",
                    "Tracks overall progression pace."
                ]
            )
        ]
    }

    var resourceText: String {
        "Ore: \(state.ore)"
    }

    var totalEarnedText: String {
        "Total ore: \(state.totalOreEarned)"
    }

    var currentPhase: Phase {
        GameState.resolvedPhase(for: state)
    }

    var isGatherPhase: Bool {
        currentPhase == .gather
    }

    var nextObjective: ObjectiveViewState? {
        if !Phase.isUnlocked(.refine, in: state) {
            return ObjectiveViewState(
                title: "Unlock Refine",
                detail: "Reach \(GameBalance.PhaseThreshold.refine) total ore to power the refiner.",
                progressText: "\(state.totalOreEarned)/\(GameBalance.PhaseThreshold.refine) ore",
                progress: progress(current: state.totalOreEarned, threshold: GameBalance.PhaseThreshold.refine)
            )
        }

        if !Phase.isUnlocked(.deliver, in: state) {
            return ObjectiveViewState(
                title: "Unlock Deliver",
                detail: "Produce \(GameBalance.PhaseThreshold.deliver) total parts to open the delivery bay.",
                progressText: "\(state.totalPartsEarned)/\(GameBalance.PhaseThreshold.deliver) parts",
                progress: progress(current: state.totalPartsEarned, threshold: GameBalance.PhaseThreshold.deliver)
            )
        }

        return ObjectiveViewState(
            title: "All Systems Online",
            detail: "Cycle phases to keep production balanced.",
            progressText: "All phases unlocked",
            progress: 1
        )
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

    func selectPhase(_ phase: Phase) {
        guard Phase.isUnlocked(phase, in: state) else { return }
        state.currentPhase = phase
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

    private func progress(current: Int, threshold: Int) -> Double {
        guard threshold > 0 else { return 1 }
        return min(Double(current) / Double(threshold), 1)
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

struct ObjectiveViewState: Identifiable {
    let id = UUID()
    let title: String
    let detail: String
    let progressText: String
    let progress: Double
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

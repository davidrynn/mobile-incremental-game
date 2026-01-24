//
//  mobile_incremental_prototypeTests.swift
//  mobile-incremental-prototypeTests
//
//  Created by David Rynn on 1/18/26.
//

import Testing
@testable import mobile_incremental_prototype

struct mobile_incremental_prototypeTests {

    @Test func primaryTapIncreasesResourceByOne() {
        let initialState = GameState(ore: 0)
        let initialHiddenState = HiddenState()

        let (updatedState, _) = apply(action: .primaryTap, to: initialState, hiddenState: initialHiddenState)

        #expect(updatedState.ore == 1)
        #expect(updatedState.totalOreEarned == 1)
    }

    @Test func applyingMultipleActionsAccumulatesResource() {
        let initialState = GameState(ore: 2)
        let initialHiddenState = HiddenState()

        let (afterFirst, afterFirstHidden) = apply(action: .primaryTap, to: initialState, hiddenState: initialHiddenState)
        let (afterSecond, _) = apply(action: .primaryTap, to: afterFirst, hiddenState: afterFirstHidden)

        #expect(afterSecond.ore == 4)
        #expect(afterSecond.totalOreEarned == 2)
    }

    @Test func purchasingPrimaryYieldUpgradeConsumesResourceAndIncreasesYield() {
        let initialState = GameState(ore: 0, parts: 12, primaryYieldLevel: 0, totalOreEarned: 5)
        let initialHiddenState = HiddenState()

        let (updatedState, _) = purchase(upgrade: .primaryYield, in: initialState, hiddenState: initialHiddenState)

        #expect(updatedState.parts == 2)
        #expect(updatedState.primaryYieldLevel == 1)
    }

    @Test func purchaseFailsWhenResourcesAreInsufficient() {
        let initialState = GameState(ore: 0, parts: 5, primaryYieldLevel: 0, totalOreEarned: 5)
        let initialHiddenState = HiddenState()

        let (updatedState, _) = purchase(upgrade: .primaryYield, in: initialState, hiddenState: initialHiddenState)

        #expect(updatedState == initialState)
    }

    @Test func upgradeCostScalesByLevel() {
        #expect(upgradeCost(for: .primaryYield, atLevel: 0) == 10)
        #expect(upgradeCost(for: .primaryYield, atLevel: 1) == 20)
        #expect(upgradeCost(for: .primaryYield, atLevel: 2) == 30)
        #expect(upgradeCost(for: .pressureValve, atLevel: 0) == 25)
        #expect(upgradeCost(for: .pressureValve, atLevel: 1) == 50)
        #expect(upgradeCost(for: .refinementCoils, atLevel: 0) == 40)
        #expect(upgradeCost(for: .displayRig, atLevel: 0) == 55)
    }

    @Test func primaryTapUsesUpgradeLevelForYield() {
        let initialState = GameState(ore: 0, primaryYieldLevel: 2, totalOreEarned: 4)
        let initialHiddenState = HiddenState()

        let (updatedState, _) = apply(action: .primaryTap, to: initialState, hiddenState: initialHiddenState)

        #expect(updatedState.ore == 3)
        #expect(updatedState.totalOreEarned == 7)
    }

    @Test func upgradeUnlocksAfterEarningThreshold() {
        let lockedState = GameState(ore: 10, primaryYieldLevel: 0, totalOreEarned: 4)

        #expect(isUpgradeUnlocked(.primaryYield, in: lockedState) == false)

        let unlockedState = GameState(ore: 10, primaryYieldLevel: 0, totalOreEarned: 5)

        #expect(isUpgradeUnlocked(.primaryYield, in: unlockedState) == true)

        let pressureValveLocked = GameState(ore: 20, primaryYieldLevel: 0, totalOreEarned: 14)
        let pressureValveUnlocked = GameState(ore: 20, primaryYieldLevel: 0, totalOreEarned: 15)

        #expect(isUpgradeUnlocked(.pressureValve, in: pressureValveLocked) == false)
        #expect(isUpgradeUnlocked(.pressureValve, in: pressureValveUnlocked) == true)
    }

    @Test func purchaseFailsWhenUpgradeIsLocked() {
        let initialState = GameState(ore: 0, parts: 20, primaryYieldLevel: 0, totalOreEarned: 4)
        let initialHiddenState = HiddenState()

        let (updatedState, _) = purchase(upgrade: .primaryYield, in: initialState, hiddenState: initialHiddenState)

        #expect(updatedState == initialState)
    }

    @Test func pressureValveImprovesReleaseFrequency() {
        let initialState = GameState(ore: 0, primaryYieldLevel: 0, pressureValveLevel: 1, totalOreEarned: 0)
        let initialHiddenState = HiddenState(pressure: 2)

        let (updatedState, updatedHiddenState) = apply(action: .primaryTap, to: initialState, hiddenState: initialHiddenState)

        #expect(updatedState.ore == 2)
        #expect(updatedState.totalOreEarned == 2)
        #expect(updatedHiddenState.pressure == 0)
    }

    @Test func gatherCadenceSweetSpotAddsStreakBonus() {
        let initialState = GameState(ore: 0, totalOreEarned: 0, gatherStreak: 0)
        let initialHiddenState = HiddenState(pressure: 0, cadenceStep: 3)

        let (updatedState, updatedHiddenState) = apply(action: .primaryTap, to: initialState, hiddenState: initialHiddenState)

        #expect(updatedState.ore == 2)
        #expect(updatedState.totalOreEarned == 2)
        #expect(updatedState.gatherStreak == 1)
        #expect(updatedHiddenState.cadenceStep == 0)
    }

    @Test func gatherCadenceMissResetsStreak() {
        let initialState = GameState(ore: 0, totalOreEarned: 0, gatherStreak: 2)
        let initialHiddenState = HiddenState(pressure: 0, cadenceStep: 1)

        let (updatedState, updatedHiddenState) = apply(action: .primaryTap, to: initialState, hiddenState: initialHiddenState)

        #expect(updatedState.ore == 1)
        #expect(updatedState.gatherStreak == 0)
        #expect(updatedHiddenState.cadenceStep == 2)
    }

    @Test func cadenceResetsOutsideGatherPhase() {
        let refineState = GameState(ore: 4, totalOreEarned: 20, gatherStreak: 2)
        let initialHiddenState = HiddenState(pressure: 0, cadenceStep: 2)

        let (updatedState, updatedHiddenState) = apply(action: .primaryTap, to: refineState, hiddenState: initialHiddenState)

        #expect(updatedState.gatherStreak == 0)
        #expect(updatedHiddenState.cadenceStep == 0)
    }

    @Test func phaseTransitionsBasedOnTotalEarned() {
        let gatherState = GameState(ore: 0, totalOreEarned: 0)
        let refineState = GameState(ore: 0, totalOreEarned: 20)
        let deliverState = GameState(ore: 0, totalOreEarned: 60)

        #expect(phase(for: gatherState) == .gather)
        #expect(phase(for: refineState) == .refine)
        #expect(phase(for: deliverState) == .deliver)
    }

    @Test func refinePhaseAmplifiesReleaseBursts() {
        let refineState = GameState(ore: 5, primaryYieldLevel: 0, pressureValveLevel: 0, totalOreEarned: 20)
        let initialHiddenState = HiddenState(pressure: 3)

        let (updatedState, updatedHiddenState) = apply(action: .primaryTap, to: refineState, hiddenState: initialHiddenState)

        #expect(updatedState.ore == 2)
        #expect(updatedState.parts == 3)
        #expect(updatedState.totalOreEarned == 20)
        #expect(updatedHiddenState.pressure == 0)
    }

    @Test func refinementCoilsIncreaseOreToPartsConversion() {
        let refineState = GameState(ore: 5, refinementCoilsLevel: 1, totalOreEarned: 20)
        let initialHiddenState = HiddenState()

        let (updatedState, _) = apply(action: .primaryTap, to: refineState, hiddenState: initialHiddenState)

        #expect(updatedState.ore == 3)
        #expect(updatedState.parts == 2)
    }

    @Test func deliverPhaseConvertsPartsIntoDisplays() {
        let deliverState = GameState(parts: 4, primaryYieldLevel: 0, pressureValveLevel: 0, totalOreEarned: 60)
        let initialHiddenState = HiddenState(pressure: 3)

        let (updatedState, updatedHiddenState) = apply(action: .primaryTap, to: deliverState, hiddenState: initialHiddenState)

        #expect(updatedState.parts == 0)
        #expect(updatedState.displays == 4)
        #expect(updatedHiddenState.pressure == 0)
    }

    @Test func displayRigBoostsDeliveryConversion() {
        let deliverState = GameState(parts: 5, displayRigLevel: 1, totalOreEarned: 60)
        let initialHiddenState = HiddenState()

        let (updatedState, _) = apply(action: .primaryTap, to: deliverState, hiddenState: initialHiddenState)

        #expect(updatedState.parts == 3)
        #expect(updatedState.displays == 2)
    }

    @Test @MainActor func upgradeViewStateShowsLockedAndRequirement() throws {
        let viewModel = DashboardViewModel(state: GameState(ore: 0, primaryYieldLevel: 0, totalOreEarned: 0))

        let upgrade = try #require(viewModel.upgrades.first)

        #expect(upgrade.isLocked == true)
        #expect(upgrade.requirementText == "Unlock at 5 total ore")
        #expect(upgrade.canPurchase == false)
    }

    @Test @MainActor func upgradeViewStateShowsCostWhenUnlocked() throws {
        let viewModel = DashboardViewModel(state: GameState(ore: 0, parts: 20, primaryYieldLevel: 1, totalOreEarned: 10))

        let upgrade = try #require(viewModel.upgrades.first)

        #expect(upgrade.isLocked == false)
        #expect(upgrade.cost == 20)
        #expect(upgrade.canPurchase == true)
    }

    @Test @MainActor func statCardsProvidePopoverDetails() throws {
        let viewModel = DashboardViewModel(state: GameState())

        let boost = try #require(viewModel.boosts.first)
        let resource = try #require(viewModel.resources.first)

        #expect(boost.description.isEmpty == false)
        #expect(boost.detailLines.isEmpty == false)
        #expect(resource.description.isEmpty == false)
        #expect(resource.detailLines.isEmpty == false)
    }

}

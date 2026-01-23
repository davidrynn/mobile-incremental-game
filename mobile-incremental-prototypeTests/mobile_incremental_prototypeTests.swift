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
        let initialState = GameState(resource: 0)
        let initialHiddenState = HiddenState()

        let (updatedState, _) = apply(action: .primaryTap, to: initialState, hiddenState: initialHiddenState)

        #expect(updatedState.resource == 1)
        #expect(updatedState.totalResourceEarned == 1)
    }

    @Test func applyingMultipleActionsAccumulatesResource() {
        let initialState = GameState(resource: 2)
        let initialHiddenState = HiddenState()

        let (afterFirst, afterFirstHidden) = apply(action: .primaryTap, to: initialState, hiddenState: initialHiddenState)
        let (afterSecond, _) = apply(action: .primaryTap, to: afterFirst, hiddenState: afterFirstHidden)

        #expect(afterSecond.resource == 4)
        #expect(afterSecond.totalResourceEarned == 2)
    }

    @Test func purchasingPrimaryYieldUpgradeConsumesResourceAndIncreasesYield() {
        let initialState = GameState(resource: 12, primaryYieldLevel: 0, totalResourceEarned: 5)
        let initialHiddenState = HiddenState()

        let (updatedState, _) = purchase(upgrade: .primaryYield, in: initialState, hiddenState: initialHiddenState)

        #expect(updatedState.resource == 2)
        #expect(updatedState.primaryYieldLevel == 1)
    }

    @Test func purchaseFailsWhenResourcesAreInsufficient() {
        let initialState = GameState(resource: 5, primaryYieldLevel: 0, totalResourceEarned: 5)
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
    }

    @Test func primaryTapUsesUpgradeLevelForYield() {
        let initialState = GameState(resource: 0, primaryYieldLevel: 2, totalResourceEarned: 4)
        let initialHiddenState = HiddenState()

        let (updatedState, _) = apply(action: .primaryTap, to: initialState, hiddenState: initialHiddenState)

        #expect(updatedState.resource == 3)
        #expect(updatedState.totalResourceEarned == 7)
    }

    @Test func upgradeUnlocksAfterEarningThreshold() {
        let lockedState = GameState(resource: 10, primaryYieldLevel: 0, totalResourceEarned: 4)

        #expect(isUpgradeUnlocked(.primaryYield, in: lockedState) == false)

        let unlockedState = GameState(resource: 10, primaryYieldLevel: 0, totalResourceEarned: 5)

        #expect(isUpgradeUnlocked(.primaryYield, in: unlockedState) == true)

        let pressureValveLocked = GameState(resource: 20, primaryYieldLevel: 0, totalResourceEarned: 14)
        let pressureValveUnlocked = GameState(resource: 20, primaryYieldLevel: 0, totalResourceEarned: 15)

        #expect(isUpgradeUnlocked(.pressureValve, in: pressureValveLocked) == false)
        #expect(isUpgradeUnlocked(.pressureValve, in: pressureValveUnlocked) == true)
    }

    @Test func purchaseFailsWhenUpgradeIsLocked() {
        let initialState = GameState(resource: 20, primaryYieldLevel: 0, totalResourceEarned: 4)
        let initialHiddenState = HiddenState()

        let (updatedState, _) = purchase(upgrade: .primaryYield, in: initialState, hiddenState: initialHiddenState)

        #expect(updatedState == initialState)
    }

    @Test func pressureValveImprovesReleaseFrequency() {
        let initialState = GameState(resource: 0, primaryYieldLevel: 0, pressureValveLevel: 1, totalResourceEarned: 0)
        let initialHiddenState = HiddenState(pressure: 2)

        let (updatedState, updatedHiddenState) = apply(action: .primaryTap, to: initialState, hiddenState: initialHiddenState)

        #expect(updatedState.resource == 2)
        #expect(updatedState.totalResourceEarned == 2)
        #expect(updatedHiddenState.pressure == 0)
    }

    @Test @MainActor func upgradeViewStateShowsLockedAndRequirement() {
        let viewModel = GameViewModel(state: GameState(resource: 0, primaryYieldLevel: 0, totalResourceEarned: 0))

        let upgrade = try #require(viewModel.upgrades.first)

        #expect(upgrade.isLocked == true)
        #expect(upgrade.requirementText == "Unlock at 5 total earned")
        #expect(upgrade.canPurchase == false)
    }

    @Test @MainActor func upgradeViewStateShowsCostWhenUnlocked() {
        let viewModel = GameViewModel(state: GameState(resource: 20, primaryYieldLevel: 1, totalResourceEarned: 10))

        let upgrade = try #require(viewModel.upgrades.first)

        #expect(upgrade.isLocked == false)
        #expect(upgrade.cost == 20)
        #expect(upgrade.canPurchase == true)
    }

}

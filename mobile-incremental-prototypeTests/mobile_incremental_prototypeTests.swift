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

        let updatedState = apply(action: .primaryTap, to: initialState)

        #expect(updatedState.resource == 1)
    }

    @Test func applyingMultipleActionsAccumulatesResource() {
        let initialState = GameState(resource: 2)

        let afterFirst = apply(action: .primaryTap, to: initialState)
        let afterSecond = apply(action: .primaryTap, to: afterFirst)

        #expect(afterSecond.resource == 4)
    }

    @Test func purchasingPrimaryYieldUpgradeConsumesResourceAndIncreasesYield() {
        let initialState = GameState(resource: 12, primaryYieldLevel: 0)

        let updatedState = purchase(upgrade: .primaryYield, in: initialState)

        #expect(updatedState.resource == 2)
        #expect(updatedState.primaryYieldLevel == 1)
    }

    @Test func purchaseFailsWhenResourcesAreInsufficient() {
        let initialState = GameState(resource: 5, primaryYieldLevel: 0)

        let updatedState = purchase(upgrade: .primaryYield, in: initialState)

        #expect(updatedState == initialState)
    }

    @Test func upgradeCostScalesByLevel() {
        #expect(upgradeCost(for: .primaryYield, atLevel: 0) == 10)
        #expect(upgradeCost(for: .primaryYield, atLevel: 1) == 20)
        #expect(upgradeCost(for: .primaryYield, atLevel: 2) == 30)
    }

    @Test func primaryTapUsesUpgradeLevelForYield() {
        let initialState = GameState(resource: 0, primaryYieldLevel: 2)

        let updatedState = apply(action: .primaryTap, to: initialState)

        #expect(updatedState.resource == 3)
    }
}

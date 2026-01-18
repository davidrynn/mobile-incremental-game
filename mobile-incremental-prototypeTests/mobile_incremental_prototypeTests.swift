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
}

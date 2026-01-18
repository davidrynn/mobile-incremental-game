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

struct GameState: Equatable {
    var resource: Int

    init(resource: Int = 0) {
        self.resource = resource
    }
}

func apply(action: ActionType, to state: GameState) -> GameState {
    var nextState = state

    switch action {
    case .primaryTap:
        nextState.resource += 1
    }

    return nextState
}

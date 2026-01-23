//
//  GameViewModel.swift
//  mobile-incremental-prototype
//
//  Created by OpenAI on 2025-02-14.
//

import Foundation

@MainActor
final class GameViewModel: ObservableObject {
    @Published private(set) var state: GameState

    init(state: GameState = GameState()) {
        self.state = state
    }

    var resourceText: String {
        "Resource: \(state.resource)"
    }

    var totalEarnedText: String {
        "Total earned: \(state.totalResourceEarned)"
    }

    func tapPrimaryAction() {
        state = apply(action: .primaryTap, to: state)
    }
}

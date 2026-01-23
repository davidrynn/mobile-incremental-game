//
//  ContentView.swift
//  mobile-incremental-prototype
//
//  Created by David Rynn on 1/18/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = GameViewModel(state: GameState())

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text(viewModel.resourceText)
                    .font(.title2)
                    .fontWeight(.semibold)
                Text(viewModel.totalEarnedText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Button(action: viewModel.tapPrimaryAction) {
                Text("Tap to Collect")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

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

            VStack(alignment: .leading, spacing: 12) {
                Text("Upgrades")
                    .font(.headline)

                ForEach(viewModel.upgrades) { upgrade in
                    Button {
                        viewModel.purchaseUpgrade(upgrade.id)
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(upgrade.title)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                Text("Level \(upgrade.level)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            VStack(alignment: .trailing, spacing: 4) {
                                if upgrade.isLocked {
                                    Text("Locked")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    if let requirementText = upgrade.requirementText {
                                        Text(requirementText)
                                            .font(.caption2)
                                            .foregroundStyle(.secondary)
                                    }
                                } else {
                                    Text("Cost \(upgrade.cost)")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(.bordered)
                    .disabled(!upgrade.canPurchase)
                }
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

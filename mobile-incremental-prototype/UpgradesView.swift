//
//  UpgradesView.swift
//  mobile-incremental-prototype
//
//  Created by OpenAI on 2025-02-14.
//

import SwiftUI

struct UpgradesView: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.09, green: 0.12, blue: 0.2), Color(red: 0.12, green: 0.18, blue: 0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    milestoneSection
                    upgradesSection
                }
                .padding()
            }
        }
        .navigationTitle("Workshop")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var milestoneSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Milestones")
                .font(.headline)
                .foregroundStyle(.white)

            ForEach(viewModel.upgrades.filter { $0.isLocked }) { upgrade in
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(upgrade.title)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                        Spacer()
                        Text("\(viewModel.state.totalOreEarned)/\(upgradeUnlockThreshold(for: upgrade.id))")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.7))
                    }
                    ProgressView(value: milestoneProgress(for: upgrade.id))
                        .tint(Color(red: 0.57, green: 0.77, blue: 0.95))
                }
                .padding(12)
                .background(.white.opacity(0.1), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            }

            if viewModel.upgrades.allSatisfy({ !$0.isLocked }) {
                HStack {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(.green)
                    Text("All upgrades unlocked")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.8))
                }
                .padding(12)
                .background(.white.opacity(0.1), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
        }
    }

    private var upgradesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Upgrades")
                .font(.headline)
                .foregroundStyle(.white)

            ForEach(viewModel.upgrades) { upgrade in
                Button {
                    viewModel.purchaseUpgrade(upgrade.id)
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(upgrade.title)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                            Text("Level \(upgrade.level)")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.7))
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 4) {
                            if upgrade.isLocked {
                                Text("Locked")
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.7))
                                if let requirementText = upgrade.requirementText {
                                    Text(requirementText)
                                        .font(.caption2)
                                        .foregroundStyle(.white.opacity(0.6))
                                }
                            } else {
                                Text("Cost \(upgrade.cost)")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.white)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 8)
                }
                .buttonStyle(.bordered)
                .tint(.white.opacity(0.15))
                .disabled(!upgrade.canPurchase)
            }
        }
        .padding()
        .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func milestoneProgress(for upgrade: UpgradeType) -> Double {
        let threshold = Double(upgradeUnlockThreshold(for: upgrade))
        guard threshold > 0 else { return 1 }
        return min(Double(viewModel.state.totalOreEarned) / threshold, 1)
    }
}

#Preview {
    UpgradesView(viewModel: GameViewModel(state: GameState()))
}

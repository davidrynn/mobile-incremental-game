//
//  UpgradesView.swift
//  mobile-incremental-prototype
//
//  Created by OpenAI on 2025-02-14.
//

import SwiftUI

struct UpgradesView: View {
    @ObservedObject var viewModel: DashboardViewModel

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
                    phaseMilestonesSection
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

    private var phaseMilestonesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Phase Unlocks")
                .font(.headline)
                .foregroundStyle(.white)

            phaseUnlockCard(
                title: "Refine",
                progress: progress(current: viewModel.state.totalOreEarned, threshold: GameBalance.PhaseThreshold.refine),
                progressText: "\(viewModel.state.totalOreEarned)/\(GameBalance.PhaseThreshold.refine) ore",
                detail: "Break ore to power the refiner."
            )

            phaseUnlockCard(
                title: "Deliver",
                progress: progress(current: viewModel.state.totalPartsEarned, threshold: GameBalance.PhaseThreshold.deliver),
                progressText: "\(viewModel.state.totalPartsEarned)/\(GameBalance.PhaseThreshold.deliver) parts",
                detail: "Refine ore into parts to open the bay."
            )
        }
    }

    private var upgradesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Upgrades")
                .font(.headline)
                .foregroundStyle(.white)

            let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 4)

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(viewModel.upgrades) { upgrade in
                    Button {
                        viewModel.purchaseUpgrade(upgrade.id)
                    } label: {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(upgrade.title)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                                .lineLimit(2)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            Text("Lv \(upgrade.level)")
                                .font(.caption2)
                                .foregroundStyle(.white.opacity(0.7))

                            Spacer(minLength: 0)

                            if upgrade.isLocked {
                                Text("Locked")
                                    .font(.caption2)
                                    .foregroundStyle(.white.opacity(0.6))
                                if let requirementText = upgrade.requirementText {
                                    Text(requirementText)
                                        .font(.caption2)
                                        .foregroundStyle(.white.opacity(0.5))
                                        .lineLimit(2)
                                }
                            } else {
                                Text("Cost \(upgrade.cost)")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.white)
                            }
                        }
                        .padding(10)
                        .frame(maxWidth: .infinity, minHeight: 96, alignment: .leading)
                        .background(.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(.white.opacity(0.2), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(!upgrade.canPurchase)
                    .opacity(upgrade.canPurchase ? 1 : 0.6)
                }
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

    private func progress(current: Int, threshold: Int) -> Double {
        guard threshold > 0 else { return 1 }
        return min(Double(current) / Double(threshold), 1)
    }

    private func phaseUnlockCard(title: String, progress: Double, progressText: String, detail: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                Spacer()
                Text(progressText)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
            }
            Text(detail)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.6))
            ProgressView(value: progress)
                .tint(Color(red: 0.57, green: 0.77, blue: 0.95))
        }
        .padding(12)
        .background(.white.opacity(0.1), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

#Preview {
    UpgradesView(viewModel: DashboardViewModel(state: GameState(), hiddenState: HiddenState()))
}

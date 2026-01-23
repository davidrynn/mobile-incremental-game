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
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.09, green: 0.12, blue: 0.2), Color(red: 0.12, green: 0.18, blue: 0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    statsSection
                    actionSection
                    pressureSection
                    milestoneSection
                    upgradesSection
                }
                .padding()
            }
        }
    }

    private var headerSection: some View {
        HStack(alignment: .center, spacing: 16) {
            ZStack {
                Circle()
                    .fill(.white.opacity(0.2))
                Image(systemName: "sparkles")
                    .font(.title)
                    .foregroundStyle(.white)
            }
            .frame(width: 52, height: 52)

            VStack(alignment: .leading, spacing: 6) {
                Text("Steamworks")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                Text("Keep the engines humming")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.7))
            }

            Spacer()
        }
    }

    private var statsSection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                statCard(title: "Resource", value: "\(viewModel.state.resource)", icon: "drop.fill")
                statCard(title: "Total Earned", value: "\(viewModel.state.totalResourceEarned)", icon: "chart.line.uptrend.xyaxis")
            }

            HStack(spacing: 16) {
                statCard(title: "Base Yield", value: "\(baseYield)", icon: "bolt.fill")
                statCard(title: "Release Rate", value: releaseRateText, icon: "gauge.with.dots.needle.bottom.50percent")
            }
        }
    }

    private var actionSection: some View {
        VStack(spacing: 12) {
            Text(viewModel.phaseText)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.white.opacity(0.8))

            Text(viewModel.actionPrompt)
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.7))

            Button(action: viewModel.tapPrimaryAction) {
                HStack(spacing: 12) {
                    Image(systemName: "hand.tap.fill")
                    Text(viewModel.actionButtonTitle)
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .padding()
            }
            .buttonStyle(.borderedProminent)
            .tint(Color(red: 0.98, green: 0.62, blue: 0.28))
        }
        .padding()
        .background(.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
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
                        Text("\(viewModel.state.totalResourceEarned)/\(upgradeUnlockThreshold(for: upgrade.id))")
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

    private var pressureSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Pressure")
                    .font(.headline)
                    .foregroundStyle(.white)

                Spacer()

                Text(viewModel.pressureStatusText)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
            }

            ProgressView(value: viewModel.pressureProgress)
                .tint(Color(red: 0.98, green: 0.62, blue: 0.28))

            Text(viewModel.pressureHintText)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.6))
        }
        .padding()
        .background(.white.opacity(0.1), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var baseYield: Int {
        1 + viewModel.state.primaryYieldLevel
    }

    private var releaseRateText: String {
        let threshold = max(1, 4 - viewModel.state.pressureValveLevel)
        if threshold <= 1 {
            return "Instant"
        }
        return "Every \(threshold)x"
    }

    private func milestoneProgress(for upgrade: UpgradeType) -> Double {
        let threshold = Double(upgradeUnlockThreshold(for: upgrade))
        guard threshold > 0 else { return 1 }
        return min(Double(viewModel.state.totalResourceEarned) / threshold, 1)
    }

    private func statCard(title: String, value: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(.white.opacity(0.7))
                Spacer()
            }
            Text(value)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
            Text(title)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.7))
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

#Preview {
    ContentView()
}

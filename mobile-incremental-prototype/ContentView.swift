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
        NavigationStack {
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
                        workshopSection
                    }
                    .padding()
                }
            }
            .navigationTitle("Steamworks")
            .navigationBarTitleDisplayMode(.inline)
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
                statCard(title: "Ore", value: "\(viewModel.state.ore)", icon: "mountain.2.fill")
                statCard(title: "Parts", value: "\(viewModel.state.parts)", icon: "gearshape.2.fill")
            }

            HStack(spacing: 16) {
                statCard(title: "Displays", value: "\(viewModel.state.displays)", icon: "photo.on.rectangle.angled")
                statCard(title: "Total Ore", value: "\(viewModel.state.totalOreEarned)", icon: "chart.line.uptrend.xyaxis")
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

    private var workshopSection: some View {
        NavigationLink {
            UpgradesView(viewModel: viewModel)
        } label: {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(.white.opacity(0.15))
                    Image(systemName: "hammer.fill")
                        .font(.title2)
                        .foregroundStyle(.white)
                }
                .frame(width: 54, height: 54)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Workshop")
                        .font(.headline)
                        .foregroundStyle(.white)
                    Text("Manage milestones and upgrade output")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundStyle(.white.opacity(0.7))
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(.plain)
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

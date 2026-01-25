//
//  ContentView.swift
//  mobile-incremental-prototype
//
//  Created by David Rynn on 1/18/26.
//

import SwiftUI

struct Dashboard: View {
    @StateObject private var viewModel = DashboardViewModel(state: GameState(), hiddenState: HiddenState())

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color(red: 0.09, green: 0.12, blue: 0.2), Color(red: 0.12, green: 0.18, blue: 0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 12) {
                    headerSection
                    phaseSwitcherSection
                    engineAnimationSection
                    phaseContent
                    workshopSection
                }
                .padding()
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
    // Placeholder view as an example
    private var engineAnimationSection: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height * 0.2
            ZStack(alignment: .topLeading) {
                ForEach(0..<viewModel.currentPhase.rawValue, id: \.self) { _ in
                    Image(systemName: "engine.combustion")
                        .resizable()
                        .scaledToFit()
                        .frame(width: width, height: height)
                }
            }
        }
    }

    @ViewBuilder
    private var phaseContent: some View {
        switch viewModel.currentPhase {
        case .gather:
            gatherPhaseSection
        case .refine:
            refinePhaseSection
        case .deliver:
            deliverPhaseSection
        }
    }

    private var gatherPhaseSection: some View {
        VStack(spacing: 20) {
            resourceSection
            actionSection
            objectiveSection
            cadenceSection
            pressureSection
            Spacer(minLength: 0)
        }
    }

    private var refinePhaseSection: some View {
        VStack(spacing: 20) {
            resourceSection
            actionSection
            objectiveSection
            pressureSection
            boostSection
            Spacer(minLength: 0)
        }
    }

    private var deliverPhaseSection: some View {
        VStack(spacing: 20) {
            resourceSection
            actionSection
            objectiveSection
            pressureSection
            boostSection
            Spacer(minLength: 0)
        }
    }

    private var resourceSection: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 4)

        return LazyVGrid(columns: columns, spacing: 12) {
            ForEach(viewModel.resources) { boost in
                StatCard(viewModel: boost )
            }
        }
    }

    private var boostSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Workshop Boosts")
                    .font(.headline)
                    .foregroundStyle(.white)
                Spacer()
            }

            let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 4)

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(viewModel.boosts) { boost in
                    StatCard(viewModel: boost )
                }
            }
        }
        .padding()
        .background(.white.opacity(0.1), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
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

    private var phaseSwitcherSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Operations")
                .font(.headline)
                .foregroundStyle(.white)

            HStack(spacing: 8) {
                ForEach(Phase.allCases, id: \.self) { phase in
                    let isUnlocked = isPhaseUnlocked(phase)
                    Button {
                        viewModel.selectPhase(phase)
                    } label: {
                        VStack(spacing: 4) {
                            Text(phase.title)
                                .font(.caption)
                                .fontWeight(.semibold)
                            Text(phase.subtitle)
                                .font(.caption2)
                                .foregroundStyle(.white.opacity(0.7))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            viewModel.currentPhase == phase
                                ? Color(red: 0.98, green: 0.62, blue: 0.28)
                                : .white.opacity(0.12),
                            in: RoundedRectangle(cornerRadius: 12, style: .continuous)
                        )
                        .foregroundStyle(isUnlocked ? .white : .white.opacity(0.5))
                    }
                    .buttonStyle(.plain)
                    .disabled(!isUnlocked)
                    .opacity(isUnlocked ? 1 : 0.6)
                }
            }
        }
        .padding()
        .background(.white.opacity(0.1), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    @ViewBuilder
    private var objectiveSection: some View {
        if let objective = viewModel.nextObjective {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(objective.title)
                        .font(.headline)
                        .foregroundStyle(.white)
                    Spacer()
                    Text(objective.progressText)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                }

                Text(objective.detail)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))

                ProgressView(value: objective.progress)
                    .tint(Color(red: 0.57, green: 0.77, blue: 0.95))
            }
            .padding()
            .background(.white.opacity(0.1), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
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

    @ViewBuilder
    private var cadenceSection: some View {
        if viewModel.isGatherPhase {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Cadence Window")
                        .font(.headline)
                        .foregroundStyle(.white)

                    Spacer()

                    Text(viewModel.cadenceStatusText)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                }

                ProgressView(value: viewModel.cadenceProgress)
                    .tint(Color(red: 0.68, green: 0.88, blue: 0.62))

                HStack {
                    Text(viewModel.cadenceHintText)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                    Spacer()
                    Text(viewModel.streakText)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
            .padding()
            .background(.white.opacity(0.1), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
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

    private func isPhaseUnlocked(_ phase: Phase) -> Bool {
        isPhaseUnlocked(phase, in: viewModel.state)
    }

}

#Preview {
    Dashboard()
}

private extension Phase {
    var title: String {
        switch self {
        case .gather:
            return "Break"
        case .refine:
            return "Refine"
        case .deliver:
            return "Deliver"
        }
    }

    var subtitle: String {
        switch self {
        case .gather:
            return "Ore"
        case .refine:
            return "Parts"
        case .deliver:
            return "Displays"
        }
    }
}

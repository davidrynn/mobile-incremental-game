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
                backgroundGradient
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 12) {
                        headerSection
                        phaseSwitcherSection
                        engineAnimationSection
                        phaseContent
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
                progressIndicator
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
            }
            .buttonStyle(ActionButtonStyle(accent: phaseAccentColor))
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
                                ? accentColor(for: phase)
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
        Phase.isUnlocked(phase, in: viewModel.state)
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

private extension Dashboard {
    var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: ambientColors(for: viewModel.currentPhase, progress: viewModel.ambientProgress),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var phaseAccentColor: Color {
        accentColor(for: viewModel.currentPhase)
    }

    var progressIndicator: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Momentum")
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.6))
            ProgressView(value: viewModel.ambientProgress)
                .tint(phaseAccentColor.opacity(0.9))
                .frame(maxWidth: 160)
                .scaleEffect(x: 1, y: 0.6, anchor: .center)
        }
    }

    func accentColor(for phase: Phase) -> Color {
        switch phase {
        case .gather:
            return Color(red: 0.98, green: 0.62, blue: 0.28)
        case .refine:
            return Color(red: 0.42, green: 0.78, blue: 0.91)
        case .deliver:
            return Color(red: 0.78, green: 0.58, blue: 0.96)
        }
    }

    func ambientColors(for phase: Phase, progress: Double) -> [Color] {
        let clamped = min(max(progress, 0.1), 1)
        let lift = 0.18 + (0.12 * clamped)
        switch phase {
        case .gather:
            return [
                liftedColor(base: (0.08, 0.11, 0.18), progress: clamped, lift: lift),
                liftedColor(base: (0.19, 0.14, 0.22), progress: clamped, lift: lift)
            ]
        case .refine:
            return [
                liftedColor(base: (0.07, 0.13, 0.2), progress: clamped, lift: lift),
                liftedColor(base: (0.1, 0.22, 0.3), progress: clamped, lift: lift)
            ]
        case .deliver:
            return [
                liftedColor(base: (0.1, 0.1, 0.2), progress: clamped, lift: lift),
                liftedColor(base: (0.2, 0.14, 0.28), progress: clamped, lift: lift)
            ]
        }
    }

    func liftedColor(base: (Double, Double, Double), progress: Double, lift: Double) -> Color {
        let factor = lift * progress
        return Color(
            red: min(base.0 + factor, 1),
            green: min(base.1 + factor, 1),
            blue: min(base.2 + factor, 1)
        )
    }
}

private struct ActionButtonStyle: ButtonStyle {
    let accent: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(accent.opacity(configuration.isPressed ? 0.85 : 1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(.white.opacity(configuration.isPressed ? 0.12 : 0.35), lineWidth: 1)
            )
            .foregroundStyle(.white)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .shadow(color: accent.opacity(configuration.isPressed ? 0.25 : 0.55), radius: configuration.isPressed ? 6 : 12, y: 6)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

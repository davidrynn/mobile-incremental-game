//
//  StatCard.swift
//  mobile-incremental-prototype
//
//  Created by David Rynn on 1/24/26.
//

import SwiftUI

struct StatCard: View {
    var viewModel: StatCardViewModel
    @State private var showPopover = false

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: viewModel.icon)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.7))
            Text(viewModel.value)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .lineLimit(1)
            Spacer(minLength: 0)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            .white.opacity(0.12),
            in: RoundedRectangle(cornerRadius: 14, style: .continuous)
        )
        .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .onTapGesture {
            showPopover = true
        }
        .popover(isPresented: $showPopover, attachmentAnchor: .rect(.bounds), arrowEdge: .top) {
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.title)
                        .font(.headline)
                    Text(viewModel.value)
                        .font(.title3)
                        .fontWeight(.semibold)
                }

                Text(viewModel.description)
                    .font(.subheadline)

                if !viewModel.detailLines.isEmpty {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Details")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        ForEach(viewModel.detailLines, id: \.self) { line in
                            Text("• \(line)")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Button("Dismiss") { showPopover = false }
                    .buttonStyle(.borderedProminent)
            }
            .padding()
            .presentationCompactAdaptation(.popover) // helps keep popover style when possible
        }
    }
}

#Preview {
    // Temporary preview view model for development
    StatCard(viewModel: StatCardViewModel(
        title: "Active Users",
        value: "1,248",
        icon: "person.3.fill",
        description: "Tracks currently active users.",
        detailLines: ["Updated every minute.", "Use trends to spot spikes."]
    ))
}

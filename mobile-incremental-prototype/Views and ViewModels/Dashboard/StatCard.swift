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
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: viewModel.icon)
                    .foregroundStyle(.white.opacity(0.7))
                Spacer()
            }
            Text(viewModel.value)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.white)

            // Optional subtitle/title line
//            Text(viewModel.title)
//                .font(.caption)
//                .foregroundStyle(.white.opacity(0.7))
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            .white.opacity(0.12),
            in: RoundedRectangle(cornerRadius: 16, style: .continuous)
        )
        .onTapGesture {
            showPopover = true
        }
        .popover(isPresented: $showPopover, attachmentAnchor: .rect(.bounds), arrowEdge: .top) {
            // Your “bubble” content
            VStack(alignment: .leading, spacing: 8) {
                Text(viewModel.title)
                    .font(.headline)
                Text(viewModel.value)
                    .font(.subheadline)
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
    StatCard(viewModel: StatCardViewModel(title: "Active Users", value: "1,248", icon: "person.3.fill"))
}

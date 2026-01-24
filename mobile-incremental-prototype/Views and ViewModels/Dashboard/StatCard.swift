//
//  StatCard.swift
//  mobile-incremental-prototype
//
//  Created by David Rynn on 1/24/26.
//

import SwiftUI

struct StatCard: View {
    let viewModel: StatCardViewModel

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
            Text(viewModel.title)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.7))
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            .white.opacity(0.12),
            in: RoundedRectangle(cornerRadius: 16, style: .continuous)
        )
        // Add popover or other interactions here when the related state and content are ready.
    }
}

#Preview {
    // Temporary preview view model for development
    StatCard(viewModel: StatCardViewModel(title: "Active Users", value: "1,248", icon: "person.3.fill"))
}

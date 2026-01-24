//
//  StatCardViewModel.swift
//  mobile-incremental-prototype
//
//  Created by David Rynn on 1/24/26.
//

import Foundation

struct StatCardViewModel: Identifiable, Equatable {
    // Provide a stable identity if needed for lists/popovers
    let id = UUID()

    let title: String
    let value: String
    let icon: String
}

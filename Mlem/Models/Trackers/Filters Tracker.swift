//
//  Filters Tracker.swift
//  Mlem
//
//  Created by David Bureš on 07.05.2023.
//

import Foundation

class FiltersTracker: ObservableObject {
    @Published var filteredKeywords: [String] = .init()
    @Published var filteredUsers: [String] = .init()
}

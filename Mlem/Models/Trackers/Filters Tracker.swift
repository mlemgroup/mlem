//
//  Filters Tracker.swift
//  Mlem
//
//  Created by David Bureš on 07.05.2023.
//

import Combine
import Dependencies
import Foundation

@MainActor
class FiltersTracker: ObservableObject {
    @Dependency(\.persistenceRepository) private var persistenceRepository
    
    @Published var filteredKeywords: [String] = .init()
    private var updateObserver: AnyCancellable?

    init() {
        _filteredKeywords = .init(initialValue: persistenceRepository.loadFilteredKeywords())
        self.updateObserver = $filteredKeywords.sink { [weak self] value in
            Task {
                try await self?.persistenceRepository.saveFilteredKeywords(value)
            }
        }
    }
}

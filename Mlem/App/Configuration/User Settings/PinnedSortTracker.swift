//
//  PinnedSortTracker.swift
//  Mlem
//
//  Created by Sjmarf on 2024-12-12.
//

import Dependencies
import Foundation
import MlemMiddleware
import Observation

@Observable
class PinnedSortTracker {
    @ObservationIgnored @Dependency(\.persistenceRepository)
    private var persistenceRepository
    
    var pinnedSortTypes: Set<ApiSortType> {
        didSet { Task.detached {
            try await self.persistenceRepository.savePinnedSortTypes(self.pinnedSortTypes)
        } }
    }
    
    init() {
        self.pinnedSortTypes = PersistenceRepository.liveValue.loadPinnedSortTypes()
    }
    
    public static let main: PinnedSortTracker = .init()
}

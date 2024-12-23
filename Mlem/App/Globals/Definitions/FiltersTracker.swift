//
//  FiltersTracker.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-12-22.
//

import Observation
import Dependencies
import Foundation
import MlemMiddleware

@Observable
class FiltersTracker {
    var moderatedCommunityIds: Set<URL>
    var filteredKeywords: Set<String>
    
    var filterContext: FilterContext {
        .init(moderatedCommunityIds: moderatedCommunityIds)
    }
    
    var changeHash: Int {
        var hasher = Hasher()
        hasher.combine(moderatedCommunityIds)
        hasher.combine(filteredKeywords)
        return hasher.finalize()
    }
    
    init() {
        @Dependency(\.persistenceRepository) var persistenceRepository
        
        moderatedCommunityIds = AppState.main.firstPerson?.moderatedCommunityIds ?? .init()
        filteredKeywords = persistenceRepository.loadFilteredKeywords()
    }
    
    static var main: FiltersTracker = .init()
}

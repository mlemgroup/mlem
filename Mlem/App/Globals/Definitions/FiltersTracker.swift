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
    var isAdmin: Bool
    var moderatedCommunityActorIds: Set<URL>
    var filteredKeywords: Set<String>
    
    var filterContext: FilterContext {
        .init(isAdmin: isAdmin, moderatedCommunityActorIds: moderatedCommunityActorIds, filteredKeywords: filteredKeywords)
    }
    
    var changeHash: Int {
        var hasher = Hasher()
        hasher.combine(moderatedCommunityActorIds)
        hasher.combine(filteredKeywords)
        return hasher.finalize()
    }
    
    init() {
        @Dependency(\.persistenceRepository) var persistenceRepository
        
        isAdmin = AppState.main.firstPerson?.isAdmin ?? false
        moderatedCommunityActorIds = AppState.main.firstPerson?.moderatedCommunityActorIds ?? .init()
        filteredKeywords = persistenceRepository.loadFilteredKeywords()
    }
    
    func postWouldBeFiltered(_ post: any Post) -> Bool {
        return post.title.lowercased().containsWordsIn(filteredKeywords)
    }
    
    static var main: FiltersTracker = .init()
}

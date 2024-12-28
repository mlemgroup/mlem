//
//  FiltersTracker.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-12-22.
//

import Dependencies
import Foundation
import MlemMiddleware
import Observation

@Observable
class FiltersTracker {
    @ObservationIgnored @Dependency(\.persistenceRepository) var persistenceRepository
    
    var isAdmin: Bool
    var moderatedCommunityActorIds: Set<URL>
    private(set) var filteredKeywords: Set<String>
    
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
        
        self.isAdmin = AppState.main.firstPerson?.isAdmin ?? false
        self.moderatedCommunityActorIds = AppState.main.firstPerson?.moderatedCommunityActorIds ?? .init()
        self.filteredKeywords = persistenceRepository.loadFilteredKeywords()
    }
    
    @MainActor
    func setFilteredKeywords(to filteredKeywords: Set<String>) {
        self.filteredKeywords = filteredKeywords
    }
    
    func addFilteredKeyword(_ keyword: String) async {
        do {
            try await setFilteredKeywords(to: persistenceRepository.saveFilteredKeywords(filteredKeywords.union([keyword])))
        } catch {
            handleError(error)
        }
    }
    
    func removeFilteredKeyword(_ keyword: String) async {
        assert(filteredKeywords.contains(keyword), "Filtered keywords does not contain \(keyword)")
        do {
            try await setFilteredKeywords(to: persistenceRepository.saveFilteredKeywords(filteredKeywords.subtracting([keyword])))
        } catch {
            handleError(error)
        }
    }
    
    func resetFilteredKeywords(to filteredKeywords: Set<String>) async {
        do {
            try await setFilteredKeywords(to: persistenceRepository.saveFilteredKeywords(filteredKeywords))
        } catch {
            handleError(error)
        }
    }
    
    func postWouldBeFiltered(_ post: any Post) -> Bool {
        post.title.lowercased().containsWordsIn(filteredKeywords)
    }
    
    static var main: FiltersTracker = .init()
}

// The persisted file serves as the source of truth for filters. Since it's much more convenient to use FiltersTracker,
// all access to the file is proxied through FiltersTracker so that FiltersTracker and the persistent file remain in sync
// and the rest of the app can treat FiltersTracker as a source of truth. Access to filters persistence is therefore
// restricted to FiltersTracker.

private extension PersistencePath {
    static var filteredKeywords = root.appendingPathComponent("Blocked Keywords", conformingTo: .json)
}

private extension PersistenceRepository {
    func loadFilteredKeywords() -> Set<String> {
        load(Set<String>.self, from: PersistencePath.filteredKeywords) ?? .init()
    }
    
    @discardableResult
    func saveFilteredKeywords(_ value: Set<String>) async throws -> Set<String> {
        try await save(value, to: PersistencePath.filteredKeywords)
        return value
    }
}

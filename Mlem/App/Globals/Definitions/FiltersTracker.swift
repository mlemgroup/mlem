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
    var moderatedCommunityActorIds: Set<ActorIdentifier>

    /// User-entered strings to filter
    private(set) var rawKeywords: Set<String>
    
    /// Single word keywords to filter
    private(set) var keywords: Set<String>
    
    /// Multi-word phrases to filter
    private(set) var phrases: Set<[String]>
    
    var keywordFilterEnabled: Bool
    
    var filterContext: FilterContext {
        .init(
            isAdmin: isAdmin,
            moderatedCommunityActorIds: moderatedCommunityActorIds,
            filteredKeywords: keywordFilterEnabled ? keywords : .init(),
            filteredPhrases: keywordFilterEnabled ? phrases : .init()
        )
    }
    
    var changeHash: Int {
        var hasher = Hasher()
        hasher.combine(moderatedCommunityActorIds)
        hasher.combine(rawKeywords)
        hasher.combine(keywordFilterEnabled)
        return hasher.finalize()
    }
    
    init() {
        @Dependency(\.persistenceRepository) var persistenceRepository
        @Setting(\.keywordFilterEnabled) var keywordFilterEnabled
        
        self.isAdmin = AppState.main.firstPerson?.isAdmin ?? false
        self.moderatedCommunityActorIds = AppState.main.firstPerson?.moderatedCommunityActorIds ?? .init()
        let rawKeywords = persistenceRepository.loadFilteredKeywords()
        self.rawKeywords = rawKeywords
        (self.keywords, self.phrases) = parseKeywordsAndPhrases(from: rawKeywords)
        self.keywordFilterEnabled = keywordFilterEnabled
    }
    
    @MainActor
    private func setFilteredKeywords(to filteredKeywords: Set<String>) {
        self.rawKeywords = filteredKeywords
        (self.keywords, self.phrases) = parseKeywordsAndPhrases(from: filteredKeywords)
    }
    
    func addFilteredKeyword(_ keyword: String) async {
        do {
            try await setFilteredKeywords(to: persistenceRepository.saveFilteredKeywords(rawKeywords.union([keyword])))
        } catch {
            handleError(error)
        }
    }
    
    func removeFilteredKeyword(_ keyword: String) async {
        assert(rawKeywords.contains(keyword), "Filtered keywords does not contain \(keyword)")
        do {
            try await setFilteredKeywords(to: persistenceRepository.saveFilteredKeywords(rawKeywords.subtracting([keyword])))
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
        keywordFilterEnabled && post.title.failsKeywordFilter(keywords: keywords, phrases: phrases)
    }
    
    static var main: FiltersTracker = .init()
}

private func parseKeywordsAndPhrases(from rawKeywords: Set<String>) -> (keywords: Set<String>, phrases: Set<[String]>) {
    var keywords: Set<String> = .init()
    var phrases: Set<[String]> = .init()
    for keyword in rawKeywords {
        if keyword.contains(" ") {
            phrases.insert(keyword.split(separator: " ").map { $0.lowercased() })
        } else {
            keywords.insert(keyword)
        }
    }
    return (keywords, phrases)
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

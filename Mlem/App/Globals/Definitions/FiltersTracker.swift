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
    @ObservationIgnored @Setting(\.filters_keywordFilterEnabled) var keywordFilterEnabled
    @ObservationIgnored @Setting(\.filters_keywords) var rawKeywords {
        didSet {
            (self.keywords, self.phrases) = parseKeywordsAndPhrases(from: rawKeywords)
        }
    }
    @ObservationIgnored @Setting(\.filters_literalFilterEnabled) var literalFilterEnabled
    @ObservationIgnored @Setting(\.filters_literals) var literals
    
    var isAdmin: Bool
    var moderatedCommunityActorIds: Set<ActorIdentifier>
    
    /// Single word keywords to filter
    private(set) var keywords: Set<String>
    
    /// Multi-word phrases to filter
    private(set) var phrases: Set<[String]>
    
    var filterContext: FilterContext {
        .init(
            isAdmin: isAdmin,
            moderatedCommunityActorIds: moderatedCommunityActorIds,
            filteredKeywords: keywordFilterEnabled ? keywords : .init(),
            filteredPhrases: keywordFilterEnabled ? phrases : .init(),
            filteredLiterals: literalFilterEnabled ? literals : .init()
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
        @Setting(\.filters_keywordFilterEnabled) var keywordFilterEnabled
        @Setting(\.filters_keywords) var rawKeywords
        
        self.isAdmin = AppState.main.firstPerson?.isAdmin ?? false
        self.moderatedCommunityActorIds = AppState.main.firstPerson?.moderatedCommunityActorIds ?? .init()
        (self.keywords, self.phrases) = parseKeywordsAndPhrases(from: rawKeywords)
    }
    
    func addFilteredKeyword(_ keyword: String) async {
        rawKeywords = rawKeywords.union([keyword])
    }
    
    func removeFilteredKeyword(_ keyword: String) async {
        assert(rawKeywords.contains(keyword), "Filtered keywords does not contain \(keyword)")
        rawKeywords = rawKeywords.subtracting([keyword])
    }
    
    func resetFilteredKeywords(to filteredKeywords: Set<String>) async {
        rawKeywords = filteredKeywords
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

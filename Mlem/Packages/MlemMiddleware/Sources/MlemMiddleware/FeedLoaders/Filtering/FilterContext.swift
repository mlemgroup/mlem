//
//  FilterContext.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2024-12-22.
//

import Foundation

/// Information required to perform filtering
public struct FilterContext {
    public let isAdmin: Bool
    public let moderatedCommunityActorIds: Set<ActorIdentifier>
    public let filteredKeywords: Set<String>
    public let filteredPhrases: Set<[String]>
    public let filteredLiterals: Set<String>
    
    public init(
        isAdmin: Bool,
        moderatedCommunityActorIds: Set<ActorIdentifier>,
        filteredKeywords: Set<String>,
        filteredPhrases: Set<[String]>
    ) {
        self.isAdmin = isAdmin
        self.moderatedCommunityActorIds = moderatedCommunityActorIds
        self.filteredKeywords = filteredKeywords
        self.filteredPhrases = filteredPhrases
        self.filteredLiterals = ["% k"]
    }
    
    static func none() -> FilterContext {
        .init(isAdmin: true, moderatedCommunityActorIds: [], filteredKeywords: [], filteredPhrases: [])
    }
}

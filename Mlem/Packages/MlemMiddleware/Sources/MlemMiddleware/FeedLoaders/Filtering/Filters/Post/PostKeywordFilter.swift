//
//  PostKeywordFilter.swift
//
//
//  Created by Eric Andrews on 2024-06-02.
//

import Foundation

class PostKeywordFilter: FilterProviding<UnifiedPostModel> {
    override public func shouldPassFilter(_ post: UnifiedPostModel) -> Bool {
        // community should always exist for posts going through the feed loader
        guard let community = post.community.value_ else {
            assertionFailure("No community found in filter-eligible post")
            return true
        }
        // bypass filter for moderated/administrated posts
        if context.isAdmin || context.moderatedCommunityActorIds.contains(community.actorId) { return true }
        
        return !post.title.failsKeywordFilter(keywords: context.filteredKeywords, phrases: context.filteredPhrases)
    }
}

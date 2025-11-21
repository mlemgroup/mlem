//
//  PostKeywordFilter.swift
//
//
//  Created by Eric Andrews on 2024-06-02.
//

import Foundation

class PostKeywordFilter: FilterProviding<Post2> {
    override public func shouldPassFilter(_ post: Post2) -> Bool {
        // bypass filter for moderated/administrated posts
        if context.isAdmin || context.moderatedCommunityActorIds.contains(post.community.actorId) { return true }
        
        return !post.title.failsKeywordFilter(keywords: context.filteredKeywords, phrases: context.filteredPhrases)
    }
}

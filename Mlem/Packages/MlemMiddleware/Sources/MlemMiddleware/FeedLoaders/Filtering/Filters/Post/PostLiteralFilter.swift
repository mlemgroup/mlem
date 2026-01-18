//
//  PostLiteralFilter.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2025-11-18.
//

import Foundation

class PostLiteralFilter: FilterProviding<Post> {
    override public func shouldPassFilter(_ post: Post) -> Bool {
        // community should always exist for posts going through the feed loader
        guard let community = post.community.value_ else {
            assertionFailure("No community found in filter-eligible post")
            return true
        }
        // bypass filter for moderated/administrated posts
        if context.isAdmin || context.moderatedCommunityActorIds.contains(community.actorId) { return true }
        
        return !post.title.failsLiteralFilter(literals: context.filteredLiterals)
    }
}

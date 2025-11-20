//
//  PostLiteralFilter.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2025-11-18.
//

import Foundation

class PostLiteralFilter: FilterProviding<Post2> {
    override public func shouldPassFilter(_ post: Post2) -> Bool {
        // bypass filter for moderated/administrated posts
        if context.isAdmin || context.moderatedCommunityActorIds.contains(post.community.actorId) { return true }
        
        return !post.title.failsLiteralFilter(literals: context.filteredLiterals)
    }
}

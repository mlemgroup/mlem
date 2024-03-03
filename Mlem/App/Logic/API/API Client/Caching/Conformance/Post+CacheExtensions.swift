//
//  Post+CacheExtensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-02.
//

import Foundation

extension Post1: CacheIdentifiable {
    var cacheId: Int {
        var hasher: Hasher = .init()
        hasher.combine(actorId)
        return hasher.finalize()
    }
    
    func update(with post: ApiPost) {
        updatedDate = post.updated
    
        title = post.name
        
        // We can't name this 'body' because @Observable uses that property name already
        content = post.body
        links = post.body?.parseLinks() ?? []
        
        linkUrl = post.linkUrl
        
        deleted = post.deleted
        
        embed = post.embed
        
        pinnedCommunity = post.featuredCommunity
        pinnedInstance = post.featuredLocal
        locked = post.locked
        nsfw = post.nsfw
        removed = post.removed
        thumbnailUrl = post.thumbnailImageUrl
    }
}

extension Post2: CacheIdentifiable {
    var cacheId: Int {
        var hasher: Hasher = .init()
        hasher.combine(actorId)
        return hasher.finalize()
    }
    
    func update(with post: ApiPostView) {
        commentCount = post.counts.comments
        votes = .init(from: post.counts, myVote: ScoringOperation.guaranteedInit(from: post.myVote))
        unreadCommentCount = post.unreadComments
        isSaved = post.saved
        isRead = post.read
        
        post1.update(with: post.post)
        creator.update(with: post.creator)
        community.update(with: post.community)
        
        creator.blocked = post.creatorBlocked
    }
}

//
//  Post+CacheExtensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-02.
//

import Foundation

extension Post1: CacheIdentifiable {
    public var cacheId: Int { id }
    
    @MainActor
    func update(with post: ApiPost, semaphore: UInt? = nil) {
        setIfChanged(\.updated, post.updated)
        setIfChanged(\.title, post.name)
        // We can't name this 'body' because @Observable uses that property name already
        setIfChanged(\.content, post.body)
        setIfChanged(\.linkUrl, post.linkUrl)
        setIfChanged(\.embed, post.embed)
        
        setIfChanged(\.nsfw, post.nsfw)
        setIfChanged(\.thumbnailUrl, post.thumbnailImageUrl)
        
        deletedManager.updateWithReceivedValue(post.deleted, semaphore: semaphore)
        pinnedCommunityManager.updateWithReceivedValue(post.featuredCommunity, semaphore: semaphore)
        pinnedInstanceManager.updateWithReceivedValue(post.featuredLocal, semaphore: semaphore)
        lockedManager.updateWithReceivedValue(post.locked, semaphore: semaphore)
        removedManager.updateWithReceivedValue(post.removed, semaphore: semaphore)
    }
}

extension Post2: CacheIdentifiable {
    public var cacheId: Int { id }
    
    @MainActor
    func update(with post: ApiPostView, semaphore: UInt? = nil) {
        setIfChanged(\.creatorIsModerator, post.creatorIsModerator)
        setIfChanged(\.creatorIsAdmin, post.creatorIsAdmin)
        creator.updateKnownCommunityBanState(id: community.id, banned: post.creatorBannedFromCommunity)
        setIfChanged(\.commentCount, post.counts.comments)
        setIfChanged(\.unreadCommentCount, post.unreadComments)
        
        savedManager.updateWithReceivedValue(post.saved ?? false, semaphore: semaphore)
        readManager.updateWithReceivedValue(post.read, semaphore: semaphore)
        hiddenManager.updateWithReceivedValue(post.hidden ?? false, semaphore: semaphore)
        votesManager.updateWithReceivedValue(
            .init(from: post.counts, myVote: ScoringOperation.guaranteedInit(from: post.myVote)),
            semaphore: semaphore
        )
        creator.blockedManager.updateWithReceivedValue(post.creatorBlocked, semaphore: semaphore)

        post1.update(with: post.post, semaphore: semaphore)
        creator.update(with: post.creator, semaphore: semaphore)
        community.update(with: post.community, semaphore: semaphore)
    }
}

extension Post3: CacheIdentifiable {
    public var cacheId: Int { id }
    
    @MainActor
    func update(with post: ApiGetPostResponse, semaphore: UInt? = nil) {
        setIfChanged(\.communityModerators, post.moderators?.map { moderatorView in
            api.caches.person1.performModelTranslation(api: api, from: moderatorView.moderator)
        } ?? [])
        
        setIfChanged(\.crossPosts, post.crossPosts.map { crossPost in
            api.caches.post2.performModelTranslation(api: api, from: crossPost)
        })
        
        post2.update(with: post.postView, semaphore: semaphore)
        community.update(with: post.communityView, semaphore: semaphore)
    }
}

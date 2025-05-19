//
//  PostCaches.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-01.
//

import Foundation

class Post1Cache: ApiTypeBackedCache<Post1, Post1Snapshot> {
    override func performModelTranslation(api: ApiClient, from snapshot: Post1Snapshot) -> Post1 {
        .init(
            api: api,
            actorId: snapshot.actorId,
            id: snapshot.id,
            creatorId: snapshot.creatorId,
            communityId: snapshot.communityId,
            created: snapshot.created,
            title: snapshot.title,
            content: snapshot.content,
            linkUrl: snapshot.linkUrl,
            deleted: snapshot.deleted,
            embed: snapshot.embed,
            pinnedCommunity: snapshot.pinnedCommunity,
            pinnedInstance: snapshot.pinnedInstance,
            locked: snapshot.locked,
            nsfw: snapshot.nsfw,
            removed: snapshot.removed,
            thumbnailUrl: snapshot.thumbnailUrl,
            updated: snapshot.updated,
            languageId: snapshot.languageId,
            altText: snapshot.altText
        )
    }
    
    override func updateModel(_ item: Post1, with snapshot: Post1Snapshot, semaphore: UInt? = nil) {
        item.update(with: snapshot, semaphore: semaphore)
    }
}

class Post2Cache: ApiTypeBackedCache<Post2, Post2Snapshot> {
    override func performModelTranslation(api: ApiClient, from snapshot: Post2Snapshot) -> Post2 {
        .init(
            api: api,
            post1: api.caches.post1.getModel(api: api, from: snapshot.post),
            creator: api.caches.person1.getModel(api: api, from: snapshot.creator),
            community: api.caches.community1.getModel(api: api, from: snapshot.community),
            votes: snapshot.votes,
            creatorIsModerator: snapshot.creatorIsModerator,
            creatorIsAdmin: snapshot.creatorIsAdmin,
            creatorBannedFromCommunity: snapshot.creatorBannedFromCommunity,
            commentCount: snapshot.commentCount,
            unreadCommentCount: snapshot.unreadCommentCount,
            saved: snapshot.saved,
            read: snapshot.read,
            hidden: snapshot.hidden
        )
    }
    
    override func updateModel(_ item: Post2, with snapshot: Post2Snapshot, semaphore: UInt? = nil) {
        item.update(with: snapshot, semaphore: semaphore)
    }
}

class Post3Cache: ApiTypeBackedCache<Post3, Post3Snapshot> {
    override func performModelTranslation(api: ApiClient, from snapshot: Post3Snapshot) -> Post3 {
        .init(
            api: api,
            post2: api.caches.post2.getModel(api: api, from: snapshot.post),
            community: api.caches.community2.getModel(api: api, from: snapshot.community),
            crossPosts: api.caches.post2.getModels(api: api, from: snapshot.crossPosts)
        )
    }
    
    override func updateModel(_ item: Post3, with snapshot: Post3Snapshot, semaphore: UInt? = nil) {
        item.update(with: snapshot, semaphore: semaphore)
    }
}

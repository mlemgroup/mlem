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
            created: snapshot.published,
            title: snapshot.name,
            content: snapshot.body,
            linkUrl: snapshot.linkUrl,
            deleted: snapshot.deleted,
            embed: snapshot.embed,
            pinnedCommunity: snapshot.featuredCommunity,
            pinnedInstance: snapshot.featuredLocal,
            locked: snapshot.locked,
            nsfw: snapshot.nsfw,
            removed: snapshot.removed,
            thumbnailUrl: snapshot.thumbnailImageUrl,
            updated: snapshot.updated,
            languageId: snapshot.languageId,
            altText: snapshot.altText
        )
    }
    
    override func updateModel(_ item: Post1, with snapshot: Post1Snapshot, semaphore: UInt? = nil) {
        item.update(with: apiType, semaphore: semaphore)
    }
}

class Post2Cache: ApiTypeBackedCache<Post2, ApiPostView> {
    override func performModelTranslation(api: ApiClient, from apiType: ApiPostView) -> Post2 {
        let votes: VotesModel
        if let counts = apiType.counts {
            votes = .init(from: counts, myVote: ScoringOperation.guaranteedInit(from: apiType.myVote))
        } else {
            votes = .init(upvotes: 0, downvotes: 0, myVote: .none)
        }
        return .init(
            api: api,
            post1: api.caches.post1.getModel(api: api, from: apiType.post),
            creator: api.caches.person1.getModel(api: api, from: apiType.creator),
            community: api.caches.community1.getModel(api: api, from: apiType.community),
            votes: votes,
            creatorIsModerator: apiType.creatorIsModerator,
            creatorIsAdmin: apiType.creatorIsAdmin,
            bannedFromCommunity: apiType.creatorBannedFromCommunity ?? false,
            commentCount: apiType.counts.comments ?? false,
            unreadCommentCount: apiType.unreadComments ?? false,
            saved: apiType.saved ?? false,
            read: apiType.read ?? false,
            hidden: apiType.hidden ?? false
        )
    }
    
    override func updateModel(_ item: Post2, with apiType: ApiPostView, semaphore: UInt? = nil) {
        item.update(with: apiType, semaphore: semaphore)
    }
}

class Post3Cache: ApiTypeBackedCache<Post3, ApiGetPostResponse> {
    override func performModelTranslation(api: ApiClient, from apiType: ApiGetPostResponse) -> Post3 {
        .init(
            api: api,
            post2: api.caches.post2.getModel(api: api, from: apiType.postView),
            community: api.caches.community2.getModel(api: api, from: apiType.communityView),
            communityModerators: apiType.moderators?.map { api.caches.person1.getModel(api: api, from: $0.moderator) } ?? [],
            crossPosts: apiType.crossPosts.map { api.caches.post2.getModel(api: api, from: $0) }
        )
    }
    
    override func updateModel(_ item: Post3, with apiType: ApiGetPostResponse, semaphore: UInt? = nil) {
        item.update(with: apiType, semaphore: semaphore)
    }
}

//
//  PostCaches.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-01.
//

import Foundation

class Post1Cache: ApiTypeBackedCache<Post1, ApiPost> {
    override func performModelTranslation(api: ApiClient, from apiType: ApiPost) -> Post1 {
        .init(
            api: api,
            actorId: apiType.actorId,
            id: apiType.id,
            creationDate: apiType.published,
            title: apiType.name,
            content: apiType.body,
            links: apiType.body?.parseLinks() ?? .init(),
            linkUrl: apiType.linkUrl,
            deleted: apiType.deleted,
            embed: apiType.embed,
            pinnedCommunity: apiType.featuredCommunity,
            pinnedInstance: apiType.featuredLocal,
            locked: apiType.locked,
            nsfw: apiType.nsfw,
            removed: apiType.removed,
            thumbnailUrl: apiType.thumbnailImageUrl,
            updatedDate: apiType.updated
        )
    }
    
    override func updateModel(_ item: Post1, with apiType: ApiPost, semaphore: UInt? = nil) {
        item.update(with: apiType)
    }
}

class Post2Cache: ApiTypeBackedCache<Post2, ApiPostView> {
    let post1Cache: Post1Cache
    let person1Cache: Person1Cache
    let community1Cache: Community1Cache
    
    init(post1Cache: Post1Cache, person1Cache: Person1Cache, community1Cache: Community1Cache) {
        self.post1Cache = post1Cache
        self.person1Cache = person1Cache
        self.community1Cache = community1Cache
    }
    
    override func performModelTranslation(api: ApiClient, from apiType: ApiPostView) -> Post2 {
        .init(
            api: api,
            post1: post1Cache.getModel(api: api, from: apiType.post),
            creator: person1Cache.getModel(api: api, from: apiType.creator),
            community: community1Cache.getModel(api: api, from: apiType.community),
            votes: .init(from: apiType.counts, myVote: ScoringOperation.guaranteedInit(from: apiType.myVote)),
            commentCount: apiType.counts.comments,
            unreadCommentCount: apiType.unreadComments,
            isSaved: apiType.saved,
            isRead: apiType.read
        )
    }
    
    override func updateModel(_ item: Post2, with apiType: ApiPostView, semaphore: UInt? = nil) {
        item.update(with: apiType, semaphore: semaphore)
    }
}

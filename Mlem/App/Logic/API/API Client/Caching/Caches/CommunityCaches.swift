//
//  CommunityCaches.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-01.
//

import Foundation

class Community1Cache: ApiTypeBackedCache<Community1, ApiCommunity> {
    override func performModelTranslation(api: ApiClient, from apiType: ApiCommunity) -> Community1 {
        .init(
            api: api,
            actorId: apiType.actorId,
            id: apiType.id,
            name: apiType.name,
            creationDate: apiType.published,
            updatedDate: apiType.updated,
            displayName: apiType.title,
            description: apiType.description,
            removed: apiType.removed,
            deleted: apiType.deleted,
            nsfw: apiType.nsfw,
            avatar: apiType.icon,
            banner: apiType.banner,
            hidden: apiType.hidden,
            onlyModeratorsCanPost: apiType.postingRestrictedToMods
        )
    }
    
    override func updateModel(_ item: Community1, with apiType: ApiCommunity, semaphore: UInt? = nil) {
        item.update(with: apiType)
    }
}

class Community2Cache: ApiTypeBackedCache<Community2, ApiCommunityView> {
    let community1Cache: Community1Cache
    
    init(community1Cache: Community1Cache) {
        self.community1Cache = community1Cache
    }
    
    override func performModelTranslation(api: ApiClient, from apiType: ApiCommunityView) -> Community2 {
        .init(
            api: api,
            community1: community1Cache.getModel(api: api, from: apiType.community),
            subscribed: apiType.subscribed.isSubscribed,
            favorited: false, // TODO: get from favorites tracker
            subscriberCount: apiType.counts.subscribers,
            postCount: apiType.counts.posts,
            commentCount: apiType.counts.comments,
            activeUserCount: .init(
                sixMonths: apiType.counts.usersActiveHalfYear,
                month: apiType.counts.usersActiveMonth,
                week: apiType.counts.usersActiveWeek,
                day: apiType.counts.usersActiveDay
            )
        )
    }
    
    override func updateModel(_ item: Community2, with apiType: ApiCommunityView, semaphore: UInt? = nil) {
        item.update(with: apiType)
    }
}

class Community3Cache: ApiTypeBackedCache<Community3, ApiGetCommunityResponse> {
    let community2Cache: Community2Cache
    let instance1Cache: Instance1Cache
    let person1Cache: Person1Cache
    
    init(
        community2Cache: Community2Cache,
        instance1Cache: Instance1Cache,
        person1Cache: Person1Cache
    ) {
        self.community2Cache = community2Cache
        self.instance1Cache = instance1Cache
        self.person1Cache = person1Cache
    }
    
    override func performModelTranslation(api: ApiClient, from apiType: ApiGetCommunityResponse) -> Community3 {
        .init(
            api: api,
            community2: community2Cache.getModel(api: api, from: apiType.communityView),
            instance: instance1Cache.getOptionalModel(api: api, from: apiType.site),
            moderators: apiType.moderators.map { person1Cache.getModel(api: api, from: $0.moderator) },
            discussionLanguages: apiType.discussionLanguages
        )
    }
}

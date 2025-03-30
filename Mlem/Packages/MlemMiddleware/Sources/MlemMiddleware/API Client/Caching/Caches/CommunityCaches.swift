//
//  CommunityCaches.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-01.
//

import Foundation

class Community1Cache: ApiTypeBackedCache<Community1, ApiCommunity> {
    @MainActor
    override func performModelTranslation(api: ApiClient, from apiType: ApiCommunity) -> Community1 {
        .init(
            api: api,
            actorId: apiType.actorId,
            id: apiType.id,
            name: apiType.name,
            created: apiType.published,
            instanceId: apiType.instanceId,
            updated: apiType.updated,
            displayName: apiType.title,
            description: apiType.description,
            removed: apiType.removed,
            deleted: apiType.deleted,
            nsfw: apiType.nsfw,
            avatar: apiType.icon,
            banner: apiType.banner,
            hidden: apiType.hidden,
            onlyModeratorsCanPost: apiType.postingRestrictedToMods,
            blocked: nil,
            visibility: apiType.visibility
        )
    }
    
    @MainActor
    override func updateModel(_ item: Community1, with apiType: ApiCommunity, semaphore: UInt? = nil) {
        item.update(with: apiType)
    }
}

class Community2Cache: ApiTypeBackedCache<Community2, ApiCommunityView> {
    @MainActor
    override func performModelTranslation(api: ApiClient, from apiType: ApiCommunityView) -> Community2 {
        .init(
            api: api,
            community1: api.caches.community1.getModel(api: api, from: apiType.community),
            subscription: .init(from: apiType.counts, subscribedType: apiType.subscribed),
            postCount: apiType.counts.posts,
            commentCount: apiType.counts.comments,
            activeUserCount: .init(
                sixMonths: apiType.counts.usersActiveHalfYear,
                month: apiType.counts.usersActiveMonth,
                week: apiType.counts.usersActiveWeek,
                day: apiType.counts.usersActiveDay
            ),
            bannedFromCommunity: apiType.bannedFromCommunity
        )
    }
    
    @MainActor
    override func updateModel(_ item: Community2, with apiType: ApiCommunityView, semaphore: UInt? = nil) {
        item.update(with: apiType, semaphore: semaphore)
    }
}

class Community3Cache: ApiTypeBackedCache<Community3, ApiGetCommunityResponse> {
    @MainActor
    override func performModelTranslation(api: ApiClient, from apiType: ApiGetCommunityResponse) -> Community3 {
        .init(
            api: api,
            community2: api.caches.community2.getModel(api: api, from: apiType.communityView),
            instance: api.caches.instance1.getOptionalModel(api: api, from: apiType.site),
            moderators: apiType.moderators.map { api.caches.person1.getModel(api: api, from: $0.moderator) },
            discussionLanguages: apiType.discussionLanguages
        )
    }
    
    @MainActor
    override func updateModel(_ item: Community3, with apiType: ApiGetCommunityResponse, semaphore: UInt? = nil) {
        item.update(with: apiType, semaphore: semaphore)
    }
}

//
//  CommunityCaches.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-01.
//

import Foundation

class Community1Cache: ApiTypeBackedCache<Community1, Community1Backer> {
    @MainActor
    override func performModelTranslation(api: ApiClient, from backer: Community1Backer) -> Community1 {
        .init(
            api: api,
            actorId: backer.actorId,
            id: backer.id,
            name: backer.name,
            created: backer.created,
            instanceId: backer.instanceId,
            updated: backer.updated,
            displayName: backer.displayName,
            description: backer.description,
            removed: backer.removed,
            deleted: backer.deleted,
            nsfw: backer.nsfw,
            avatar: backer.avatar,
            banner: backer.banner,
            hidden: backer.hidden,
            onlyModeratorsCanPost: backer.onlyModeratorsCanPost,
            blocked: nil,
            visibility: backer.visibility
        )
    }
    
    @MainActor
    override func updateModel(_ item: Community1, with backer: Community1Backer, semaphore: UInt? = nil) {
        item.update(with: backer)
    }
}

class Community2Cache: ApiTypeBackedCache<Community2, ApiCommunityView> {
    @MainActor
    override func performModelTranslation(api: ApiClient, from apiType: ApiCommunityView) -> Community2 {
        .init(
            api: api,
            community1: api.caches.community1.getModel(api: api, from: apiType.community),
            subscription: .init(from: apiType.counts, subscribedType: apiType.subscribed),
            postCount: apiType.counts?.posts ?? 0,
            commentCount: apiType.counts?.comments ?? 0,
            activeUserCount: .init(
                sixMonths: apiType.counts?.usersActiveHalfYear ?? 0,
                month: apiType.counts?.usersActiveMonth ?? 0,
                week: apiType.counts?.usersActiveWeek ?? 0,
                day: apiType.counts?.usersActiveDay ?? 0
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

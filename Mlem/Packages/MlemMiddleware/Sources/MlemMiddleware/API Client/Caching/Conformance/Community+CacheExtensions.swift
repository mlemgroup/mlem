//
//  Community+CacheExtensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-02.
//

import Foundation

extension Community1: CacheIdentifiable {
    public var cacheId: Int { id }
    
    @MainActor
    func update(with community: Community1Backer, semaphore: UInt? = nil) {
        setIfChanged(\.updated, community.updated)
        setIfChanged(\.displayName, community.displayName)
        setIfChanged(\.description, community.description)
        setIfChanged(\.deleted, community.deleted)
        setIfChanged(\.nsfw, community.nsfw)
        setIfChanged(\.avatar, community.avatar)
        setIfChanged(\.banner, community.banner)
        setIfChanged(\.hidden, community.hidden)
        setIfChanged(\.onlyModeratorsCanPost, community.onlyModeratorsCanPost)
        setIfChanged(\.visibility, community.visibility)
        
        removedManager.updateWithReceivedValue(community.removed, semaphore: semaphore)
    }
}

extension Community2: CacheIdentifiable {
    public var cacheId: Int { id }
    
    @MainActor
    func update(with communityView: ApiCommunityView, semaphore: UInt? = nil) {
        setIfChanged(\.postCount, communityView.counts?.posts ?? 0)
        setIfChanged(\.commentCount, communityView.counts?.comments ?? 0)
        setIfChanged(\.activeUserCount, .init(
            sixMonths: communityView.counts?.usersActiveHalfYear ?? 0,
            month: communityView.counts?.usersActiveMonth ?? 0,
            week: communityView.counts?.usersActiveWeek ?? 0,
            day: communityView.counts?.usersActiveDay ?? 0
        ))
        
        if let counts = communityView.counts, let subscribed = communityView.subscribed {
            subscriptionManager.updateWithReceivedValue(
                .init(from: counts, subscribedType: subscribed),
                semaphore: semaphore
            )
        }
        
        community1.update(with: communityView.community, semaphore: semaphore)
    }
}

extension Community3: CacheIdentifiable {
    public var cacheId: Int { id }
    
    @MainActor
    func update(with response: ApiGetCommunityResponse, semaphore: UInt? = nil) {
        setIfChanged(\.moderators, response.moderators.map { moderatorView in
            api.caches.person1.performModelTranslation(api: api, from: moderatorView.moderator)
        })
        setIfChanged(\.discussionLanguages, response.discussionLanguages)

        community2.update(with: response.communityView, semaphore: semaphore)
    }
}

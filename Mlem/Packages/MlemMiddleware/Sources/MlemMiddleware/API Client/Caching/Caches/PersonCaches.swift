//
//  PersonCaches.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-01.
//

import Foundation

class Person1Cache: ApiTypeBackedCache<Person1, ApiPerson> {
    @MainActor
    override func performModelTranslation(api: ApiClient, from apiType: ApiPerson) -> Person1 {
        let instanceBan: InstanceBanType
        if apiType.banned {
            if let expires = apiType.banExpires {
                instanceBan = .temporarilyBanned(expires: expires)
            } else {
                instanceBan = .permanentlyBanned
            }
        } else {
            instanceBan = .notBanned
        }

        return .init(
            api: api,
            actorId: apiType.actorId,
            id: apiType.id,
            name: apiType.name,
            created: apiType.published,
            instanceId: apiType.instanceId,
            updated: apiType.updated,
            displayName: apiType.displayName ?? apiType.name,
            description: apiType.bio,
            matrixId: apiType.matrixUserId,
            avatar: apiType.avatar,
            banner: apiType.banner,
            deleted: apiType.deleted,
            isBot: apiType.botAccount,
            instanceBan: instanceBan,
            blocked: nil
        )
    }
    
    @MainActor
    override func updateModel(_ item: Person1, with apiType: ApiPerson, semaphore: UInt? = nil) {
        item.update(with: apiType, semaphore: semaphore)
    }
}

// Person2 can be created from any Person2ApiBacker, so we can't use ApiTypeBackedCache
class Person2Cache: CoreCache<Person2> {
    @MainActor
    func getModel(
        api: ApiClient,
        from apiType: any Person2ApiBacker,
        isStale: Bool = false,
        semaphore: UInt? = nil
    ) -> Person2 {
        if let item = retrieveModel(cacheId: apiType.cacheId) {
            if !isStale {
                item.update(with: apiType, semaphore: semaphore)
            }
            return item
        }
        
        let newItem: Person2 = .init(
            api: api,
            person1: api.caches.person1.getModel(api: api, from: apiType.person),
            postCount: apiType.counts.postCount,
            commentCount: apiType.counts.commentCount,
            isAdmin: apiType.admin
        )
        itemCache.put(newItem)
        return newItem
    }
    
    @MainActor
    func getModels(
        api: ApiClient,
        from apiTypes: [any Person2ApiBacker],
        isStale: Bool = false,
        semaphore: UInt? = nil
    ) -> [Person2] {
        apiTypes.map { getModel(api: api, from: $0, isStale: isStale, semaphore: semaphore) }
    }
}

// Person3 can be created from any Person3ApiBacker, so can't use ApiTypeBackedCache
class Person3Cache: CoreCache<Person3> {
    @MainActor
    func getModel(api: ApiClient, from apiType: any Person3ApiBacker) -> Person3 {
        let moderatedCommunities = apiType.moderates.map { moderatedCommunity in
            api.caches.community1.getModel(api: api, from: moderatedCommunity.community)
        }
        
        if let item = retrieveModel(cacheId: apiType.cacheId) {
            item.update(moderatedCommunities: moderatedCommunities, person2ApiBacker: apiType.person2ApiBacker)
            return item
        }
        
        let newItem: Person3 = .init(
            api: api,
            person2: api.caches.person2.getModel(api: api, from: apiType.person2ApiBacker),
            instance: api.caches.instance1.getOptionalModel(api: api, from: apiType.site),
            moderatedCommunities: moderatedCommunities
        )
        itemCache.put(newItem)
        return newItem
    }
}

class Person4Cache: ApiTypeBackedCache<Person4, ApiMyUserInfo> {
    @MainActor
    override func performModelTranslation(api: ApiClient, from apiType: ApiMyUserInfo) -> Person4 {
        let user = apiType.localUserView.localUser
        return .init(
            api: api,
            person3: api.caches.person3.getModel(api: api, from: apiType),
            voteDisplayMode: apiType.localUserView.localUserVoteDisplayMode,
            email: user.email,
            showNsfw: user.showNsfw,
            theme: user.theme,
            defaultSortType: user.defaultSortType ?? .hot, // TODO: 0.20 support: we shouldn't be coalescing to .hot here
            defaultListingType: user.defaultListingType,
            interfaceLanguage: user.interfaceLanguage,
            showAvatars: user.showAvatars,
            sendNotificationsToEmail: user.sendNotificationsToEmail,
            showScores: user.showScores ?? true, // TODO: 0.20 support: we shouldn't be coalescing to true here
            showBotAccounts: user.showBotAccounts,
            showReadPosts: user.showReadPosts,
            discussionLanguageIds: .init(apiType.discussionLanguages.filter { $0 != 0 }),
            showNewPostNotifs: user.showNewPostNotifs,
            emailVerified: user.emailVerified,
            acceptedApplication: user.acceptedApplication,
            openLinksInNewTab: user.openLinksInNewTab,
            blurNsfw: user.blurNsfw,
            autoExpandImages: user.autoExpand,
            infiniteScrollEnabled: user.infiniteScrollEnabled,
            postListingMode: user.postListingMode,
            totp2faEnabled: user.totp2faEnabled,
            enableKeyboardNavigation: user.enableKeyboardNavigation,
            enableAnimatedImages: user.enableAnimatedImages,
            collapseBotComments: user.collapseBotComments
        )
    }
    
    @MainActor
    override func updateModel(_ item: Person4, with apiType: ApiMyUserInfo, semaphore: UInt? = nil) {
        item.update(with: apiType, semaphore: semaphore)
    }
}

//
//  PersonCaches.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-01.
//

import Foundation

class Person1Cache: ApiTypeBackedCache<Person1, Person1Backer> {
    @MainActor
    override func performModelTranslation(api: ApiClient, from backer: Person1Backer) -> Person1 {
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
            matrixId: backer.matrixUserId,
            avatar: backer.avatar,
            banner: backer.banner,
            deleted: backer.deleted,
            isBot: backer.isBot,
            instanceBan: backer.instanceBan,
            blocked: nil
        )
    }
    
    @MainActor
    override func updateModel(_ item: Person1, with apiType: Person1Backer, semaphore: UInt? = nil) {
        item.update(with: apiType, semaphore: semaphore)
    }
}

class Person2Cache: ApiTypeBackedCache<Person2, Person2Backer> {
    @MainActor
    override func performModelTranslation(api: ApiClient, from backer: Person2Backer) -> Person2 {
        .init(
            api: api,
            person1: api.caches.person1.getModel(api: api, from: backer.person),
            postCount: backer.postCount,
            commentCount: backer.commentCount,
            isAdmin: backer.isAdmin
        )
    }
    
    @MainActor
    override func updateModel(_ item: Person2, with apiType: Person2Backer, semaphore: UInt? = nil) {
        item.update(with: apiType, semaphore: semaphore)
    }
}

class Person3Cache: ApiTypeBackedCache<Person3, Person3Backer> {
    @MainActor
    override func performModelTranslation(api: ApiClient, from backer: Person3Backer) -> Person3 {
        let moderatedCommunities = backer.moderatedCommunities.map {
            api.caches.community1.getModel(api: api, from: $0.community)
        }
        return .init(
            api: api,
            person2: api.caches.person2.getModel(api: api, from: backer.person),
            instance: api.caches.instance1.getOptionalModel(api: api, from: backer.site),
            moderatedCommunities: moderatedCommunities
        )
    }
    
    @MainActor
    override func updateModel(_ item: Person3, with person: Person3Backer, semaphore: UInt? = nil) {
        item.update(with: person, semaphore: semaphore)
    }
}

class Person4Cache: ApiTypeBackedCache<Person4, Person4Backer> {
    @MainActor
    override func performModelTranslation(api: ApiClient, from backer: Person4Backer) -> Person4 {
        .init(
            api: api,
            person3: api.caches.person3.getModel(api: api, from: backer.person),
            voteDisplayMode: backer.voteDisplayMode,
            email: backer.email,
            showNsfw: backer.showNsfw,
            theme: backer.theme,
            defaultListingType: backer.defaultListingType,
            interfaceLanguage: backer.interfaceLanguage,
            showAvatars: backer.showAvatars,
            sendNotificationsToEmail: backer.sendNotificationsToEmail,
            showScores: backer.showScores,
            showBotAccounts: backer.showBotAccounts,
            showReadPosts: backer.showReadPosts,
            discussionLanguageIds: backer.discussionLanguageIds,
            showNewPostNotifs: backer.showNewPostNotifs,
            emailVerified: backer.emailVerified,
            acceptedApplication: backer.acceptedApplication,
            openLinksInNewTab: backer.openLinksInNewTab,
            blurNsfw: backer.blurNsfw,
            autoExpandImages: backer.autoExpandImages,
            infiniteScrollEnabled: backer.infiniteScrollEnabled,
            postListingMode: backer.postListingMode,
            totp2faEnabled: backer.totp2faEnabled,
            enableKeyboardNavigation: backer.enableKeyboardNavigation,
            enableAnimatedImages: backer.enableAnimatedImages,
            collapseBotComments: backer.collapseBotComments
        )
    }
    
    @MainActor
    override func updateModel(_ item: Person4, with backer: Person4Backer, semaphore: UInt? = nil) {
        item.update(with: backer, semaphore: semaphore)
    }
}

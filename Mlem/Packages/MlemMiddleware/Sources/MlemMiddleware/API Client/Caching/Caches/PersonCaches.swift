//
//  PersonCaches.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-01.
//

import Foundation

class Person1Cache: ApiTypeBackedCache<Person1, Person1Snapshot> {
    @MainActor
    override func performModelTranslation(api: ApiClient, from snapshot: Person1Snapshot) -> Person1 {
        .init(
            api: api,
            actorId: snapshot.actorId,
            id: snapshot.id,
            name: snapshot.name,
            created: snapshot.created,
            instanceId: snapshot.instanceId,
            updated: snapshot.updated,
            displayName: snapshot.displayName,
            description: snapshot.description,
            matrixId: snapshot.matrixUserId,
            avatar: snapshot.avatar,
            banner: snapshot.banner,
            deleted: snapshot.deleted,
            isBot: snapshot.isBot,
            instanceBan: snapshot.instanceBan,
            blocked: nil
        )
    }
    
    @MainActor
    override func updateModel(_ item: Person1, with apiType: Person1Snapshot, semaphore: UInt? = nil) {
        item.update(with: apiType, semaphore: semaphore)
    }
}

class Person2Cache: ApiTypeBackedCache<Person2, Person2Snapshot> {
    @MainActor
    override func performModelTranslation(api: ApiClient, from snapshot: Person2Snapshot) -> Person2 {
        .init(
            api: api,
            person1: api.caches.person1.getModel(api: api, from: snapshot.person),
            postCount: snapshot.postCount,
            commentCount: snapshot.commentCount,
            isAdmin: snapshot.isAdmin
        )
    }
    
    @MainActor
    override func updateModel(_ item: Person2, with apiType: Person2Snapshot, semaphore: UInt? = nil) {
        item.update(with: apiType, semaphore: semaphore)
    }
}

class Person3Cache: ApiTypeBackedCache<Person3, Person3Snapshot> {
    @MainActor
    override func performModelTranslation(api: ApiClient, from snapshot: Person3Snapshot) -> Person3 {
        .init(
            api: api,
            person2: api.caches.person2.getModel(api: api, from: snapshot.person),
            instance: api.caches.instance1.getOptionalModel(api: api, from: snapshot.site),
            moderatedCommunities: api.caches.community1.getModels(api: api, from: snapshot.moderatedCommunities)
        )
    }
    
    @MainActor
    override func updateModel(_ item: Person3, with person: Person3Snapshot, semaphore: UInt? = nil) {
        item.update(with: person, semaphore: semaphore)
    }
}

class Person4Cache: ApiTypeBackedCache<Person4, Person4Snapshot> {
    @MainActor
    override func performModelTranslation(api: ApiClient, from snapshot: Person4Snapshot) -> Person4 {
        .init(
            api: api,
            person3: api.caches.person3.getModel(api: api, from: snapshot.person),
            voteDisplayMode: snapshot.voteDisplayMode,
            email: snapshot.email,
            showNsfw: snapshot.showNsfw,
            theme: snapshot.theme,
            defaultListingType: snapshot.defaultListingType,
            interfaceLanguage: snapshot.interfaceLanguage,
            showAvatars: snapshot.showAvatars,
            sendNotificationsToEmail: snapshot.sendNotificationsToEmail,
            showScores: snapshot.showScores,
            showBotAccounts: snapshot.showBotAccounts,
            showReadPosts: snapshot.showReadPosts,
            discussionLanguageIds: snapshot.discussionLanguageIds,
            emailVerified: snapshot.emailVerified,
            acceptedApplication: snapshot.acceptedApplication,
            openLinksInNewTab: snapshot.openLinksInNewTab,
            blurNsfw: snapshot.blurNsfw,
            autoExpandImages: snapshot.autoExpandImages,
            infiniteScrollEnabled: snapshot.infiniteScrollEnabled,
            postListingMode: snapshot.postListingMode,
            totp2faEnabled: snapshot.totp2faEnabled,
            enableKeyboardNavigation: snapshot.enableKeyboardNavigation,
            enableAnimatedImages: snapshot.enableAnimatedImages,
            collapseBotComments: snapshot.collapseBotComments
        )
    }
    
    @MainActor
    override func updateModel(_ item: Person4, with snapshot: Person4Snapshot, semaphore: UInt? = nil) {
        item.update(with: snapshot, semaphore: semaphore)
    }
}

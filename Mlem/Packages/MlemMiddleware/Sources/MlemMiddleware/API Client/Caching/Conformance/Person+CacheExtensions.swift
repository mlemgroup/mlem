//
//  Person+CacheExtensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-02.
//

import Foundation

extension Person1: CacheIdentifiable {
    public var cacheId: Int { id }
    
    @MainActor
    func update(with snapshot: Person1Snapshot, semaphore: UInt? = nil) {
        setIfChanged(\.displayName, snapshot.displayName)
        setIfChanged(\.avatar, snapshot.avatar)
        setIfChanged(\.banner, snapshot.banner)
        setIfChanged(\.updated, snapshot.updated)
        setIfChanged(\.description, snapshot.description)
        setIfChanged(\.matrixId, snapshot.matrixUserId)
        setIfChanged(\.isBot, snapshot.isBot)
        setIfChanged(\.instanceBan, snapshot.instanceBan)
        setIfChanged(\.deleted, snapshot.deleted)
    }
}

extension Person2: CacheIdentifiable {
    public var cacheId: Int { id }
    
    @MainActor
    func update(with snapshot: Person2Snapshot, semaphore: UInt? = nil) {
        person1.update(with: snapshot.person, semaphore: semaphore)
        
        setIfChanged(\.isAdmin, snapshot.isAdmin)
        setIfChanged(\.postCount, snapshot.postCount)
        setIfChanged(\.commentCount, snapshot.commentCount)
    }
}

extension Person3: CacheIdentifiable {
    public var cacheId: Int { id }
    
    @MainActor
    func update(with snapshot: Person3Snapshot, semaphore: UInt? = nil) {
        person2.update(with: snapshot.person, semaphore: semaphore)
        if let site = snapshot.site {
            instance?.update(with: site)
        }
        
        moderatedCommunities = api.caches.community1.getModels(api: api, from: snapshot.moderatedCommunities)
    }
}

extension Person4: CacheIdentifiable {
    public var cacheId: Int { id }
    
    @MainActor
    func update(with snapshot: Person4Snapshot, semaphore: UInt? = nil) {
        person3.update(with: snapshot.person, semaphore: semaphore)
        
        setIfChanged(\.email, snapshot.email)
        setIfChanged(\.showNsfw, snapshot.showNsfw)
        setIfChanged(\.theme, snapshot.theme)
        setIfChanged(\.defaultListingType, snapshot.defaultListingType)
        setIfChanged(\.interfaceLanguage, snapshot.interfaceLanguage)
        setIfChanged(\.showAvatars, snapshot.showAvatars)
        setIfChanged(\.sendNotificationsToEmail, snapshot.sendNotificationsToEmail)
        setIfChanged(\.showScores, snapshot.showScores)
        setIfChanged(\.showBotAccounts, snapshot.showBotAccounts)
        setIfChanged(\.showReadPosts, snapshot.showReadPosts)
        setIfChanged(\.discussionLanguageIds, snapshot.discussionLanguageIds)
        setIfChanged(\.emailVerified, snapshot.emailVerified)
        setIfChanged(\.acceptedApplication, snapshot.acceptedApplication)
        setIfChanged(\.openLinksInNewTab, snapshot.openLinksInNewTab)
        setIfChanged(\.blurNsfw, snapshot.blurNsfw)
        setIfChanged(\.autoExpandImages, snapshot.autoExpandImages)
        setIfChanged(\.infiniteScrollEnabled, snapshot.infiniteScrollEnabled)
        setIfChanged(\.postListingMode, snapshot.postListingMode)
        setIfChanged(\.totp2faEnabled, snapshot.totp2faEnabled)
        setIfChanged(\.enableKeyboardNavigation, snapshot.enableKeyboardNavigation)
        setIfChanged(\.enableAnimatedImages, snapshot.enableAnimatedImages)
        setIfChanged(\.collapseBotComments, snapshot.collapseBotComments)
    }
}

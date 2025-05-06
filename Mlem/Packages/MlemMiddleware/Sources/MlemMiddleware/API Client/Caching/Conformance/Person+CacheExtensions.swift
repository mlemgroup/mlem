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
    func update(with backer: Person1Snapshot, semaphore: UInt? = nil) {
        setIfChanged(\.displayName, backer.displayName)
        setIfChanged(\.avatar, backer.avatar)
        setIfChanged(\.banner, backer.banner)
        setIfChanged(\.updated, backer.updated)
        setIfChanged(\.description, backer.description)
        setIfChanged(\.matrixId, backer.matrixUserId)
        setIfChanged(\.isBot, backer.isBot)
        setIfChanged(\.instanceBan, backer.instanceBan)
        setIfChanged(\.deleted, backer.deleted)
    }
}

extension Person2: CacheIdentifiable {
    public var cacheId: Int { id }
    
    @MainActor
    func update(with backer: Person2Snapshot, semaphore: UInt? = nil) {
        person1.update(with: backer.person, semaphore: semaphore)
        
        setIfChanged(\.isAdmin, backer.isAdmin)
        setIfChanged(\.postCount, backer.postCount)
        setIfChanged(\.commentCount, backer.commentCount)
    }
}

extension Person3: CacheIdentifiable {
    public var cacheId: Int { id }
    
    @MainActor
    func update(with backer: Person3Snapshot, semaphore: UInt? = nil) {
        person2.update(with: backer.person, semaphore: semaphore)
        if let site = backer.site {
            instance?.update(with: site)
        }
        
        moderatedCommunities = api.caches.community1.getModels(api: api, from: backer.moderatedCommunities)
    }
}

extension Person4: CacheIdentifiable {
    public var cacheId: Int { id }
    
    @MainActor
    func update(with backer: Person4Snapshot, semaphore: UInt? = nil) {
        person3.update(with: backer.person, semaphore: semaphore)
        
        setIfChanged(\.voteDisplayMode, backer.voteDisplayMode)
        setIfChanged(\.email, backer.email)
        setIfChanged(\.showNsfw, backer.showNsfw)
        setIfChanged(\.theme, backer.theme)
        setIfChanged(\.defaultListingType, backer.defaultListingType)
        setIfChanged(\.interfaceLanguage, backer.interfaceLanguage)
        setIfChanged(\.showAvatars, backer.showAvatars)
        setIfChanged(\.sendNotificationsToEmail, backer.sendNotificationsToEmail)
        setIfChanged(\.showScores, backer.showScores)
        setIfChanged(\.showBotAccounts, backer.showBotAccounts)
        setIfChanged(\.showReadPosts, backer.showReadPosts)
        setIfChanged(\.discussionLanguageIds, backer.discussionLanguageIds)
        setIfChanged(\.showNewPostNotifs, backer.showNewPostNotifs)
        setIfChanged(\.emailVerified, backer.emailVerified)
        setIfChanged(\.acceptedApplication, backer.acceptedApplication)
        setIfChanged(\.openLinksInNewTab, backer.openLinksInNewTab)
        setIfChanged(\.blurNsfw, backer.blurNsfw)
        setIfChanged(\.autoExpandImages, backer.autoExpandImages)
        setIfChanged(\.infiniteScrollEnabled, backer.infiniteScrollEnabled)
        setIfChanged(\.postListingMode, backer.postListingMode)
        setIfChanged(\.totp2faEnabled, backer.totp2faEnabled)
        setIfChanged(\.enableKeyboardNavigation, backer.enableKeyboardNavigation)
        setIfChanged(\.enableAnimatedImages, backer.enableAnimatedImages)
        setIfChanged(\.collapseBotComments, backer.collapseBotComments)
    }
}

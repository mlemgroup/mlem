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
    func update(with person: ApiPerson, semaphore: UInt? = nil) {
        setIfChanged(\.updated, person.updated)
        setIfChanged(\.displayName, person.displayName ?? person.name)
        setIfChanged(\.description, person.bio)
        setIfChanged(\.avatar, person.avatar)
        setIfChanged(\.banner, person.banner)
        
        setIfChanged(\.deleted, person.deleted)
        setIfChanged(\.isBot, person.botAccount)
        
        let newInstanceBan: InstanceBanType
        if person.banned {
            if let expires = person.banExpires {
                newInstanceBan = .temporarilyBanned(expires: expires)
            } else {
                newInstanceBan = .permanentlyBanned
            }
        } else {
            newInstanceBan = .notBanned
        }
        setIfChanged(\.instanceBan, newInstanceBan)
    }
}

extension Person2: CacheIdentifiable {
    public var cacheId: Int { id }
    
    @MainActor
    func update(with apiType: any Person2ApiBacker, semaphore: UInt? = nil) {
        setIfChanged(\.isAdmin, apiType.admin)
        setIfChanged(\.postCount, apiType.counts.postCount)
        setIfChanged(\.commentCount, apiType.counts.commentCount)
        person1.update(with: apiType.person, semaphore: semaphore)
    }
}

extension Person3: CacheIdentifiable {
    public var cacheId: Int { id }
    
    @MainActor
    func update(moderatedCommunities: [Community1], person2ApiBacker: any Person2ApiBacker, semaphore: UInt? = nil) {
        setIfChanged(\.self.moderatedCommunities, moderatedCommunities)
        person2.update(with: person2ApiBacker, semaphore: semaphore)
    }
}

extension Person4: CacheIdentifiable {
    public var cacheId: Int { id }
    
    @MainActor
    func update(with apiMyUserInfo: ApiMyUserInfo, semaphore: UInt? = nil) {
        let moderates = apiMyUserInfo.moderates.map { moderatorView in
            api.caches.community1.performModelTranslation(api: api, from: moderatorView.community)
        }
        
        let user = apiMyUserInfo.localUserView.localUser
        
        if let admin = user.admin {
            setIfChanged(\.person2.isAdmin, admin)
        }
        setIfChanged(\.voteDisplayMode, apiMyUserInfo.localUserView.localUserVoteDisplayMode)
        setIfChanged(\.email, user.email)
        setIfChanged(\.showNsfw, user.showNsfw)
        setIfChanged(\.theme, user.theme)
        setIfChanged(\.defaultSortType, user.defaultSortType ?? .hot) // TODO: 0.20 support: we shouldn't be .hot to true here
        setIfChanged(\.defaultListingType, user.defaultListingType)
        setIfChanged(\.interfaceLanguage, user.interfaceLanguage)
        setIfChanged(\.showAvatars, user.showAvatars)
        setIfChanged(\.sendNotificationsToEmail, user.sendNotificationsToEmail)
        setIfChanged(\.showScores, user.showScores ?? true) // // TODO 0.20 support: we shouldn't be coalescing to true here
        setIfChanged(\.showBotAccounts, user.showBotAccounts)
        setIfChanged(\.showReadPosts, user.showReadPosts)
        setIfChanged(\.discussionLanguageIds, .init(apiMyUserInfo.discussionLanguages.filter { $0 != 0 }))
        setIfChanged(\.showNewPostNotifs, user.showNewPostNotifs)
        setIfChanged(\.emailVerified, user.emailVerified)
        setIfChanged(\.acceptedApplication, user.acceptedApplication)
        setIfChanged(\.openLinksInNewTab, user.openLinksInNewTab)
        setIfChanged(\.blurNsfw, user.blurNsfw)
        setIfChanged(\.autoExpandImages, user.autoExpand)
        setIfChanged(\.infiniteScrollEnabled, user.infiniteScrollEnabled)
        setIfChanged(\.postListingMode, user.postListingMode)
        setIfChanged(\.totp2faEnabled, user.totp2faEnabled)
        setIfChanged(\.enableKeyboardNavigation, user.enableKeyboardNavigation)
        setIfChanged(\.enableAnimatedImages, user.enableAnimatedImages)
        setIfChanged(\.collapseBotComments, user.collapseBotComments)
        
        person3.update(
            moderatedCommunities: moderates,
            person2ApiBacker: apiMyUserInfo.localUserView,
            semaphore: semaphore
        )
    }
}

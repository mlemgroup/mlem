//
//  Instance+CacheExtensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-02.
//

import Foundation

extension Instance1: CacheIdentifiable {
    public var cacheId: Int { id }
    
    @MainActor
    func update(with snapshot: Instance1Snapshot) {
        setIfChanged(\.updated, snapshot.updated)
        setIfChanged(\.publicKey, snapshot.publicKey)
        setIfChanged(\.displayName, snapshot.displayName)
        setIfChanged(\.description, snapshot.description)
        setIfChanged(\.shortDescription, snapshot.shortDescription)
        setIfChanged(\.avatar, snapshot.avatar)
        setIfChanged(\.banner, snapshot.banner)
        setIfChanged(\.lastRefresh, snapshot.lastRefresh)
        setIfChanged(\.contentWarning, snapshot.contentWarning)
    }
}

extension Instance2: CacheIdentifiable {
    public var cacheId: Int { id }
    
    @MainActor
    func update(with snapshot: Instance2Snapshot) {
        instance1.update(with: snapshot.instance)
        
        setIfChanged(\.setup, snapshot.setup)
        setIfChanged(\.downvotesEnabled, snapshot.downvotesEnabled)
        setIfChanged(\.nsfwContentEnabled, snapshot.nsfwContentEnabled)
        setIfChanged(\.communityCreationRestrictedToAdmins, snapshot.communityCreationRestrictedToAdmins)
        setIfChanged(\.emailVerificationRequired, snapshot.emailVerificationRequired)
        setIfChanged(\.applicationQuestion, snapshot.applicationQuestion)
        setIfChanged(\.isPrivate, snapshot.isPrivate)
        setIfChanged(\.defaultTheme, snapshot.defaultTheme)
        setIfChanged(\.defaultFeed, snapshot.defaultFeed)
        setIfChanged(\.legalInformation, snapshot.legalInformation)
        setIfChanged(\.hideModlogNames, snapshot.hideModlogNames)
        setIfChanged(\.emailApplicationsToAdmins, snapshot.emailApplicationsToAdmins)
        setIfChanged(\.emailReportsToAdmins, snapshot.emailReportsToAdmins)
        setIfChanged(\.slurFilterRegex, snapshot.slurFilterRegex)
        setIfChanged(\.actorNameMaxLength, snapshot.actorNameMaxLength)
        setIfChanged(\.federationEnabled, snapshot.federationEnabled)
        setIfChanged(\.captchaEnabled, snapshot.captchaEnabled)
        setIfChanged(\.captchaDifficulty, snapshot.captchaDifficulty)
        setIfChanged(\.registrationMode, snapshot.registrationMode)
        setIfChanged(\.federationSignedFetch, snapshot.federationSignedFetch)
        setIfChanged(\.defaultPostListingMode, snapshot.defaultPostListingMode)
        setIfChanged(\.defaultPostSortType, snapshot.defaultPostSortType)
        setIfChanged(\.userCount, snapshot.userCount)
        setIfChanged(\.postCount, snapshot.postCount)
        setIfChanged(\.commentCount, snapshot.commentCount)
        setIfChanged(\.communityCount, snapshot.communityCount)
        setIfChanged(\.activeUserCount, snapshot.activeUserCount)
    }
}

extension Instance3: CacheIdentifiable {
    public var cacheId: Int { id }
    
    @MainActor
    func update(with snapshot: Instance3Snapshot) {
        instance2.update(with: snapshot.instance)
        
        setIfChanged(\.version, snapshot.version)
        setIfChanged(\.allowedLanguageIds, snapshot.allowedLanguageIds)
        setIfChanged(\.blockedUrls, snapshot.blockedUrls)
        setIfChanged(\.administrators, api.caches.person2.getModels(api: api, from: snapshot.administrators))
    }
}

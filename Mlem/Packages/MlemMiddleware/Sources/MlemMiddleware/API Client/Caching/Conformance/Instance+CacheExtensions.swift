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
    func update(with site: ApiSite) {
        setIfChanged(\.displayName, site.name)
        setIfChanged(\.description, site.sidebar)
        setIfChanged(\.shortDescription, site.description)
        setIfChanged(\.avatar, site.icon)
        setIfChanged(\.banner, site.banner)
        setIfChanged(\.lastRefresh, site.lastRefreshedAt)
        setIfChanged(\.contentWarning, site.contentWarning)
    }
}

extension Instance2: CacheIdentifiable {
    public var cacheId: Int { id }
    
    @MainActor
    func update(with siteView: ApiSiteView) {
        setIfChanged(\.setup, siteView.localSite.siteSetup)
        setIfChanged(\.downvotesEnabled, siteView.localSite.enableDownvotes ?? true) // TODO 0.20 support: we shouldn't be coalescing to true here
        setIfChanged(\.nsfwContentEnabled, siteView.localSite.enableNsfw ?? false) // TODO 0.20 support: we shouldn't be coalescing to false here
        setIfChanged(\.communityCreationRestrictedToAdmins, siteView.localSite.communityCreationAdminOnly)
        setIfChanged(\.emailVerificationRequired, siteView.localSite.requireEmailVerification)
        setIfChanged(\.applicationQuestion, siteView.localSite.applicationQuestion)
        setIfChanged(\.isPrivate, siteView.localSite.privateInstance)
        setIfChanged(\.defaultTheme, siteView.localSite.defaultTheme)
        setIfChanged(\.defaultFeed, siteView.localSite.defaultPostListingType)
        setIfChanged(\.legalInformation, siteView.localSite.legalInformation)
        setIfChanged(\.hideModlogNames, siteView.localSite.hideModlogModNames)
        setIfChanged(\.emailApplicationsToAdmins, siteView.localSite.applicationEmailAdmins)
        setIfChanged(\.emailReportsToAdmins, siteView.localSite.reportsEmailAdmins)
        setIfChanged(\.slurFilterRegex, siteView.localSite.slurFilterRegex)
        setIfChanged(\.actorNameMaxLength, siteView.localSite.actorNameMaxLength)
        setIfChanged(\.federationEnabled, siteView.localSite.federationEnabled)
        setIfChanged(\.captchaEnabled, siteView.localSite.captchaEnabled)
        setIfChanged(\.captchaDifficulty, .init(rawValue: siteView.localSite.captchaDifficulty))
        setIfChanged(\.registrationMode, siteView.localSite.registrationMode)
        setIfChanged(\.federationSignedFetch, siteView.localSite.federationSignedFetch)
        setIfChanged(\.defaultPostListingMode, siteView.localSite.defaultPostListingMode)
        setIfChanged(\.defaultSortType, siteView.localSite.defaultSortType)
        setIfChanged(\.userCount, siteView.counts.users)
        setIfChanged(\.postCount, siteView.counts.posts)
        setIfChanged(\.commentCount, siteView.counts.comments)
        setIfChanged(\.communityCount, siteView.counts.communities)
        setIfChanged(\.activeUserCount, .init(
            sixMonths: siteView.counts.usersActiveHalfYear,
            month: siteView.counts.usersActiveMonth,
            week: siteView.counts.usersActiveWeek,
            day: siteView.counts.usersActiveDay
        ))
        
        instance1.update(with: siteView.site)
    }
}

extension Instance3: CacheIdentifiable {
    public var cacheId: Int { id }
    
    @MainActor
    func update(with response: ApiGetSiteResponse) {
        setIfChanged(\.version, SiteVersion(response.version))
        setIfChanged(\.allowedLanguageIds, Set(response.discussionLanguages).subtracting([0]))
        setIfChanged(\.taglines, response.taglines ?? [response.tagline].compactMap { $0 })
        setIfChanged(\.customEmojis, response.customEmojis ?? []) // TODO 0.20 support: we shouldn't be coalescing to [] here
        setIfChanged(\.blockedUrls, response.blockedUrls)
        setIfChanged(\.administrators, response.admins.map { api.caches.person2.getModel(api: api, from: $0) })
        
        instance2.update(with: response.siteView)
    }
}

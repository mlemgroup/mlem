//
//  InstanceCaches.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-01.
//

import Foundation

class Instance1Cache: CoreCache<Instance1> {
    public var instanceIdCache: ItemCache = .init()
    
    @MainActor
    func getModel(api: ApiClient, from apiType: ApiSite, semaphore: UInt? = nil) -> Instance1 {
        if let item = retrieveModel(cacheId: apiType.cacheId) {
            item.update(with: apiType)
            return item
        }
    
        let newItem: Instance1 = .init(
            api: api,
            actorId: apiType.actorId,
            id: apiType.id,
            instanceId: apiType.instanceId,
            created: apiType.published,
            updated: apiType.updated,
            publicKey: apiType.publicKey,
            displayName: apiType.name,
            description: apiType.sidebar,
            shortDescription: apiType.description,
            avatar: apiType.icon,
            banner: apiType.banner,
            lastRefresh: apiType.lastRefreshedAt,
            contentWarning: apiType.contentWarning,
            blocked: nil
        )
        
        itemCache.put(newItem)
        instanceIdCache.put(newItem, overrideCacheId: newItem.instanceId)
        return newItem
    }
    
    @MainActor
    func getModels(api: ApiClient, from apiTypes: [ApiSite], semaphore: UInt? = nil) -> [Instance1] {
        apiTypes.map { getModel(api: api, from: $0, semaphore: semaphore) }
    }
    
    /// Get an instance with the given `instanceId` - this is different from the `id` of the instance.
    public func retrieveModel(instanceId: Int) -> Instance1? {
        instanceIdCache.get(instanceId)
    }
    
    override func clean() {
        Task {
            await itemCache.clean()
            await instanceIdCache.clean()
        }
    }
    
    /// Convenience method for getting an optional site
    @MainActor
    func getOptionalModel(api: ApiClient, from apiType: ApiSite?) -> Instance1? {
        if let apiType {
            return getModel(api: api, from: apiType)
        }
        return nil
    }
}

class Instance2Cache: ApiTypeBackedCache<Instance2, ApiSiteView> {
    @MainActor
    override func performModelTranslation(api: ApiClient, from apiType: ApiSiteView) -> Instance2 {
        .init(
            api: api,
            instance1: api.caches.instance1.getModel(api: api, from: apiType.site),
            setup: apiType.localSite.siteSetup,
            downvotesEnabled: apiType.localSite.enableDownvotes ?? true, // TODO: 0.20 support: we shouldn't be coalescing to true here
            nsfwContentEnabled: apiType.localSite.enableNsfw ?? false, // TODO: 0.20 support: we shouldn't be coalescing to false here
            communityCreationRestrictedToAdmins: apiType.localSite.communityCreationAdminOnly,
            emailVerificationRequired: apiType.localSite.requireEmailVerification,
            applicationQuestion: apiType.localSite.applicationQuestion,
            isPrivate: apiType.localSite.privateInstance,
            defaultTheme: apiType.localSite.defaultTheme,
            defaultFeed: apiType.localSite.defaultPostListingType,
            legalInformation: apiType.localSite.legalInformation,
            hideModlogNames: apiType.localSite.hideModlogModNames,
            emailApplicationsToAdmins: apiType.localSite.applicationEmailAdmins,
            emailReportsToAdmins: apiType.localSite.reportsEmailAdmins,
            slurFilterRegex: apiType.localSite.slurFilterRegex,
            actorNameMaxLength: apiType.localSite.actorNameMaxLength,
            federationEnabled: apiType.localSite.federationEnabled,
            captchaEnabled: apiType.localSite.captchaEnabled,
            captchaDifficulty: .init(rawValue: apiType.localSite.captchaDifficulty),
            registrationMode: apiType.localSite.registrationMode,
            federationSignedFetch: apiType.localSite.federationSignedFetch,
            defaultPostListingMode: apiType.localSite.defaultPostListingMode,
            defaultSortType: apiType.localSite.defaultSortType,
            userCount: apiType.counts.users,
            postCount: apiType.counts.posts,
            commentCount: apiType.counts.comments,
            communityCount: apiType.counts.communities,
            activeUserCount: .init(
                sixMonths: apiType.counts.usersActiveHalfYear,
                month: apiType.counts.usersActiveMonth,
                week: apiType.counts.usersActiveWeek,
                day: apiType.counts.usersActiveDay
            )
        )
    }
    
    @MainActor
    override func updateModel(_ item: Instance2, with apiType: ApiSiteView, semaphore: UInt? = nil) {
        item.update(with: apiType)
    }
}

class Instance3Cache: ApiTypeBackedCache<Instance3, ApiGetSiteResponse> {
    @MainActor
    override func performModelTranslation(api: ApiClient, from apiType: ApiGetSiteResponse) -> Instance3 {
        .init(
            api: api,
            instance2: api.caches.instance2.getModel(api: api, from: apiType.siteView),
            version: .init(apiType.version),
            allLanguages: apiType.allLanguages.compactMap { .init($0) },
            allowedLanguageIds: Set(apiType.discussionLanguages).subtracting([0]),
            taglines: apiType.taglines ?? [apiType.tagline].compactMap { $0 },
            customEmojis: apiType.customEmojis ?? [], // TODO: 0.20 support: we shouldn't be coalescing to [] here
            blockedUrls: apiType.blockedUrls,
            administrators: apiType.admins.map { api.caches.person2.getModel(api: api, from: $0) }
        )
    }
    
    @MainActor
    override func updateModel(_ item: Instance3, with apiType: ApiGetSiteResponse, semaphore: UInt? = nil) {
        item.update(with: apiType)
    }
}

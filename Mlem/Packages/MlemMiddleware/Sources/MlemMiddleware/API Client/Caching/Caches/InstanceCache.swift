//
//  InstanceCaches.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-01.
//

import Foundation

public enum AnyInstanceSnapshot: CacheIdentifiable {
    case instance1(Instance1Snapshot)
    case instance2(Instance2Snapshot)
    case instance3(Instance3Snapshot)
    
    public var cacheId: Int {
        switch self {
        case let .instance1(snapshot): snapshot.cacheId
        case let .instance2(snapshot): snapshot.cacheId
        case let .instance3(snapshot): snapshot.cacheId
        }
    }
}

class InstanceCache: CoreCache<Instance> {
    public var instanceIdCache: ItemCache = .init()
    
    @MainActor
    func getModel(api: ApiClient, from snapshot: AnyInstanceSnapshot) -> Instance {
        if let item = retrieveModel(cacheId: snapshot.cacheId) {
            item.update(with: .init(api: api, snapshot: snapshot))
            return item
        }
    
        let newItem: Instance = .init(
            api: api,
            properties: .init(api: api, snapshot: snapshot)
        )
        
        itemCache.put(newItem)
        instanceIdCache.put(newItem, overrideCacheId: newItem.instanceId)
        return newItem
    }
    
    @MainActor
    func getModels(api: ApiClient, from snapshots: [AnyInstanceSnapshot]) -> [Instance] {
        snapshots.map { getModel(api: api, from: $0) }
    }
    
    /// Get an instance with the given `instanceId` - this is different from the `id` of the instance.
    public func retrieveModel(instanceId: Int) -> Instance? {
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
    func getOptionalModel(api: ApiClient, from snapshot: AnyInstanceSnapshot?) -> Instance? {
        if let snapshot {
            return getModel(api: api, from: snapshot)
        }
        return nil
    }
}

// TODO: NOW remove below this point

class Instance1Cache: CoreCache<Instance1> {
    public var instanceIdCache: ItemCache = .init()
    
    @MainActor
    func getModel(api: ApiClient, from snapshot: Instance1Snapshot, semaphore: UInt? = nil) -> Instance1 {
        if let item = retrieveModel(cacheId: snapshot.cacheId) {
            item.update(with: snapshot)
            return item
        }
    
        let newItem: Instance1 = .init(
            api: api,
            actorId: snapshot.actorId,
            id: snapshot.id,
            instanceId: snapshot.instanceId,
            created: snapshot.created,
            updated: snapshot.updated,
            publicKey: snapshot.publicKey,
            displayName: snapshot.displayName,
            description: snapshot.description,
            shortDescription: snapshot.shortDescription,
            avatar: snapshot.avatar,
            banner: snapshot.banner,
            lastRefresh: snapshot.lastRefresh,
            contentWarning: snapshot.contentWarning,
            blocked: nil
        )
        
        itemCache.put(newItem)
        instanceIdCache.put(newItem, overrideCacheId: newItem.instanceId)
        return newItem
    }
    
    @MainActor
    func getModels(api: ApiClient, from snapshots: [Instance1Snapshot], semaphore: UInt? = nil) -> [Instance1] {
        snapshots.map { getModel(api: api, from: $0, semaphore: semaphore) }
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
    func getOptionalModel(api: ApiClient, from snapshot: Instance1Snapshot?) -> Instance1? {
        if let snapshot {
            return getModel(api: api, from: snapshot)
        }
        return nil
    }
}

class Instance2Cache: ApiTypeBackedCache<Instance2, Instance2Snapshot> {
    @MainActor
    override func performModelTranslation(api: ApiClient, from snapshot: Instance2Snapshot) -> Instance2 {
        .init(
            api: api,
            instance1: api.caches.instance1.getModel(api: api, from: snapshot.instance),
            setup: snapshot.setup,
            voteFederationMode: snapshot.voteFederationMode,
            nsfwContentEnabled: snapshot.nsfwContentEnabled,
            communityCreationRestrictedToAdmins: snapshot.communityCreationRestrictedToAdmins,
            emailVerificationRequired: snapshot.emailVerificationRequired,
            applicationQuestion: snapshot.applicationQuestion,
            isPrivate: snapshot.isPrivate,
            defaultTheme: snapshot.defaultTheme,
            defaultFeed: snapshot.defaultFeed,
            legalInformation: snapshot.legalInformation,
            hideModlogNames: snapshot.hideModlogNames,
            emailApplicationsToAdmins: snapshot.emailApplicationsToAdmins,
            emailReportsToAdmins: snapshot.emailReportsToAdmins,
            slurFilterRegex: snapshot.slurFilterRegex,
            actorNameMaxLength: snapshot.actorNameMaxLength,
            federationEnabled: snapshot.federationEnabled,
            captchaEnabled: snapshot.captchaEnabled,
            captchaDifficulty: snapshot.captchaDifficulty,
            registrationMode: snapshot.registrationMode,
            federationSignedFetch: snapshot.federationSignedFetch,
            defaultPostListingMode: snapshot.defaultPostListingMode,
            defaultPostSortType: snapshot.defaultPostSortType,
            userCount: snapshot.userCount,
            postCount: snapshot.postCount,
            commentCount: snapshot.commentCount,
            communityCount: snapshot.communityCount,
            activeUserCount: snapshot.activeUserCount
        )
    }
    
    @MainActor
    override func updateModel(_ item: Instance2, with snapshot: Instance2Snapshot, semaphore: UInt? = nil) {
        item.update(with: snapshot)
    }
}

//class Instance3Cache: ApiTypeBackedCache<Instance3, Instance3Snapshot> {
//    @MainActor
//    override func performModelTranslation(api: ApiClient, from snapshot: Instance3Snapshot) -> Instance3 {
//        .init(
//            api: api,
//            instance2: api.caches.instance2.getModel(api: api, from: snapshot.instance),
//            software: snapshot.software,
//            allLanguages: snapshot.allLanguages,
//            allowedLanguageIds: snapshot.allowedLanguageIds,
//            blockedUrls: snapshot.blockedUrls,
//            administrators: api.caches.person.getModels(api: api, from: snapshot.administrators.map { .person2($0) })
//        )
//    }
//    
//    @MainActor
//    override func updateModel(_ item: Instance3, with snapshot: Instance3Snapshot, semaphore: UInt? = nil) {
//        item.update(with: snapshot)
//    }
//}

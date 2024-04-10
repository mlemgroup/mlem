//
//  InstanceCaches.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-01.
//

import Foundation

class Instance1Cache: ApiTypeBackedCache<Instance1, ApiSite> {
    override func performModelTranslation(api: ApiClient, from apiType: ApiSite) -> Instance1 {
        .init(
            api: api,
            id: apiType.id,
            creationDate: apiType.published,
            publicKey: apiType.publicKey,
            displayName: apiType.name,
            description: apiType.sidebar,
            avatar: apiType.icon,
            banner: apiType.banner,
            lastRefreshDate: apiType.lastRefreshedAt
        )
    }
    
    override func updateModel(_ item: Instance1, with apiType: ApiSite, semaphore: UInt? = nil) {
        item.update(with: apiType)
    }
    
    /// Convenience method for getting an optional site
    func getOptionalModel(api: ApiClient, from apiType: ApiSite?) -> Instance1? {
        if let apiType {
            return getModel(api: api, from: apiType)
        }
        return nil
    }
}

class Instance2Cache: ApiTypeBackedCache<Instance2, ApiSiteView> {
    let instance1Cache: Instance1Cache
    
    init(instance1Cache: Instance1Cache) {
        self.instance1Cache = instance1Cache
    }
    
    override func performModelTranslation(api: ApiClient, from apiType: ApiSiteView) -> Instance2 {
        .init(api: api, instance1: instance1Cache.getModel(api: api, from: apiType.site))
    }
    
    override func updateModel(_ item: Instance2, with apiType: ApiSiteView, semaphore: UInt? = nil) {
        item.update(with: apiType)
    }
}

class Instance3Cache: ApiTypeBackedCache<Instance3, ApiGetSiteResponse> {
    let instance2Cache: Instance2Cache
    
    init(instance2Cache: Instance2Cache) {
        self.instance2Cache = instance2Cache
    }
    
    override func performModelTranslation(api: ApiClient, from apiType: ApiGetSiteResponse) -> Instance3 {
        .init(
            api: api,
            instance2: instance2Cache.getModel(api: api, from: apiType.siteView),
            version: .init(apiType.version)
        )
    }
    
    override func updateModel(_ item: Instance3, with apiType: ApiGetSiteResponse, semaphore: UInt? = nil) {
        item.update(with: apiType)
    }
}

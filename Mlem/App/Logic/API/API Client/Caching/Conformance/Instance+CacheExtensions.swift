//
//  Instance+CacheExtensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-02.
//

import Foundation

extension Instance1: CacheIdentifiable {
    // Instance and ApiClient share equatability properties--two instances are different iff they are different servers and being connected to using a different user. This makes intuitive sense given that instance is the source of things like post feeds, which can vary depending on the calling user (even instance-generics like All and Local will produce varying responses for different calling users, e.g., return an upvoted or neutral post)
    var cacheId: Int { api.cacheId }
    
    func update(with site: ApiSite) {
        displayName = site.name
        description = site.sidebar
        avatar = site.icon
        banner = site.banner
        lastRefreshDate = site.lastRefreshedAt
    }
}

extension Instance2: CacheIdentifiable {
    var cacheId: Int { instance1.cacheId }
    
    func update(with siteView: ApiSiteView) {
        instance1.update(with: siteView.site)
    }
}

extension Instance3: CacheIdentifiable {
    var cacheId: Int { instance2.cacheId }
    
    func update(with response: ApiGetSiteResponse) {
        version = SiteVersion(response.version)
        instance2.update(with: response.siteView)
    }
}

//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-05-11.
//

import Foundation

public struct Instance3Snapshot: CacheIdentifiable {
    // Won't change, but the corresponding models need to
    // be updated within the `update` method of Instance3.
    public let instance: Instance2Snapshot
    
    // Won't Change.
    public let allLanguages: [Locale.Language]

    // May change. If you add/remove items from this list,
    // remember to also amend the `update` method of Instance3!
    public let software: SiteSoftware
    // This excludes the "undetermined" language identifier (which is 0),
    // because its presence or absence doesn't actually affect whether you're
    // able to create a post with "undetermined" as the language
    public var allowedLanguageIds: Set<Int>
    public let blockedUrls: [InstanceUrlBlockRecord]?
    public let administrators: [Person2Snapshot]

    public var cacheId: Int { instance.cacheId }
    
    public init(from site: LemmyGetSiteResponse) throws(ApiClientError) {
        self.instance = try .init(from: site.siteView)
        self.software = .init(type: .lemmy, version: .init(site.version))
        self.allLanguages = site.allLanguages.compactMap { .init($0) }
        self.allowedLanguageIds = Set(site.discussionLanguages).subtracting([0])
        
        self.blockedUrls = site.blockedUrls?.compactMap { .init(from: $0) }
    
        var administrators: [Person2Snapshot] = []
        administrators.reserveCapacity(site.admins.count)
        for admin in site.admins {
            try administrators.append(.init(from: admin))
        }
        self.administrators = administrators
    }
}

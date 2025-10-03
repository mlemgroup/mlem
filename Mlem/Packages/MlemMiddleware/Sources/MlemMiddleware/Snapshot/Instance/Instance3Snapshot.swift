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
    
    public init(
        instance: Instance2Snapshot,
        allLanguages: [Locale.Language],
        software: SiteSoftware,
        allowedLanguageIds: Set<Int>,
        blockedUrls: [InstanceUrlBlockRecord]?,
        administrators: [Person2Snapshot]
    ) {
        self.instance = instance
        self.allLanguages = allLanguages
        self.software = software
        self.allowedLanguageIds = allowedLanguageIds
        self.blockedUrls = blockedUrls
        self.administrators = administrators
    }
}

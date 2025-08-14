//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-14.
//

import Foundation

public extension Instance1Snapshot {
    init(from site: PieFedSite) throws(ApiClientError) {
        self.actorId = site.actorId
        
        // This is kinda dodgy
        self.id = site.actorId.hashValue
        self.instanceId = site.actorId.hashValue
        
        self.created = Date(timeIntervalSince1970: 0)
        self.updated = nil
        self.publicKey = ""
        
        self.displayName = site.name
        self.description = site.sidebarMd ?? site.sidebar
        self.shortDescription = site.description
        self.avatar = site.icon
        self.banner = nil
        
        self.lastRefresh = Date(timeIntervalSince1970: 0)
        self.contentWarning = nil
    }
}

//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-07-14.
//

import Foundation

extension Instance1Snapshot {
    init(from site: LemmySite) throws(ApiClientError) {
        if let actorId = site.apId ?? site.actorId {
            self.actorId = actorId
        } else {
            throw .responseMissingRequiredData("LemmySite actorId")
        }
        
        self.id = site.id
        self.instanceId = site.instanceId
        
        if let published = site.publishedAt ?? site.published {
            self.created = published
        } else {
            throw .responseMissingRequiredData("LemmySite published")
        }

        self.updated = site.updatedAt ?? site.updated
        self.publicKey = site.publicKey
        self.displayName = site.name
        self.description = site.sidebar
        self.shortDescription = site.description
        self.avatar = site.icon
        self.banner = site.banner
        self.lastRefresh = site.lastRefreshedAt
        self.contentWarning = site.contentWarning
    }
}

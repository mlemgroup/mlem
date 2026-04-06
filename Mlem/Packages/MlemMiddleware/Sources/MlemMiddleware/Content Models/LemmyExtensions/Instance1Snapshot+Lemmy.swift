//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-07-14.
//

import Foundation

extension Instance1Snapshot {
    init(from site: LemmySite) throws(ApiClientError) {
        guard let actorId = site.apId ?? site.actorId else {
            throw .responseMissingRequiredData("LemmySite actorId")
        }
        
        guard let published = site.publishedAt ?? site.published else {
            throw .responseMissingRequiredData("LemmySite published")
        }

        self.init(
            actorId: actorId,
            id: site.id,
            instanceId: site.instanceId,
            created: published,
            updated: site.updatedAt ?? site.updated,
            publicKey: site.publicKey ?? "",
            displayName: site.name,
            description: site.sidebar,
            shortDescription: site.description,
            avatar: site.icon,
            banner: site.banner,
            lastRefresh: site.lastRefreshedAt,
            contentWarning: site.contentWarning
        )
    }
}

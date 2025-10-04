//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-07-14.
//

import Foundation

extension Community1Snapshot {
    init(from community: LemmyCommunity) throws(ApiClientError) {
        guard let actorId = community.apId ?? community.actorId else {
            throw .responseMissingRequiredData("LemmyCommunity actorId")
        }
        
        guard let published = community.publishedAt ?? community.published else {
            throw .responseMissingRequiredData("LemmyCommunity published")
        }
        
        self.init(
            actorId: actorId,
            id: community.id,
            name: community.name,
            created: published,
            instanceId: community.instanceId,
            updated: community.updatedAt ?? community.updated,
            displayName: community.title,
            description: community.description,
            deleted: community.deleted,
            removed: community.removed,
            nsfw: community.nsfw,
            avatar: community.icon,
            banner: community.banner,
            hidden: community.hidden ?? false, // TODO: 0.20 we shouldn't be null coalescing here
            onlyModeratorsCanPost: community.postingRestrictedToMods,
            allPropertiesPresent: true
        )
     }
}

//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-07-14.
//

import Foundation

extension Community1Snapshot {
    init(from community: LemmyCommunity) throws(ApiClientError) {
        if let actorId = community.apId ?? community.actorId {
            self.actorId = actorId
        } else {
            throw .responseMissingRequiredData("LemmyCommunity actorId")
        }
        
        self.id = community.id
        self.name = community.name
        
        if let published = community.publishedAt ?? community.published {
            self.created = published
        } else {
            throw .responseMissingRequiredData("LemmyCommunity published")
        }
        
        self.instanceId = community.instanceId
        
        self.updated = community.updatedAt ?? community.updated
        self.displayName = community.title
        self.description = community.description
        self.removed = community.removed
        self.deleted = community.deleted
        self.nsfw = community.nsfw
        self.avatar = community.icon
        self.banner = community.banner
        self.hidden = community.hidden ?? false // TODO: 0.20 we shouldn't be null coalescing here
        self.onlyModeratorsCanPost = community.postingRestrictedToMods
        
        self.allPropertiesPresent = true
    }
}

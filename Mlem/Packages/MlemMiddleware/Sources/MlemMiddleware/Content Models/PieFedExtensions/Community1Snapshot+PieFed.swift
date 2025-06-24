//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-19.
//

import Foundation

public extension Community1Snapshot {
    init(from community: PieFedCommunity, allPropertiesPresent: Bool = false) throws(ApiClientError) {
        self.actorId = community.actorId
        self.id = community.id
        self.name = community.name
        self.created = community.published
        self.instanceId = community.instanceId
        self.updated = community.updated
        self.displayName = community.title
        self.description = community.description
        self.removed = community.removed
        self.deleted = community.deleted
        self.nsfw = community.nsfw
        self.avatar = community.icon
        self.banner = community.banner
        self.hidden = community.hidden
        self.onlyModeratorsCanPost = false
        self.allPropertiesPresent = allPropertiesPresent
    }
}

//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-19.
//

import Foundation

public extension Community1Snapshot {
    init(from community: PieFedCommunity, allPropertiesPresent: Bool = false) throws(ApiClientError) {
        self.init(
            actorId: community.actorId,
            id: community.id,
            name: community.name,
            created: community.published,
            instanceId: community.instanceId,
            updated: community.updated,
            displayName: community.title,
            description: community.description,
            deleted: community.deleted,
            removed: community.removed,
            nsfw: community.nsfw,
            avatar: community.icon,
            banner: community.banner,
            hidden: community.hidden,
            onlyModeratorsCanPost: community.restrictedToMods,
            allPropertiesPresent: allPropertiesPresent
        )
    }
}

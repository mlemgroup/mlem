//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-19.
//

import Foundation

public extension Community1Snapshot {
    init(from community: PieFedCommunity, descriptionAndBannerProvided: Bool = false) throws(ApiClientError) {
        self.init(
            actorId: community.actorId,
            id: community.id,
            name: community.name,
            created: community.published,
            instanceId: community.instanceId,
            updated: community.updated,
            displayName: community.title,
            description: descriptionAndBannerProvided ? .init(community.description) : .notProvided,
            deleted: community.deleted,
            removed: community.removed,
            nsfw: community.nsfw,
            avatar: community.icon,
            banner: descriptionAndBannerProvided ? .init(community.banner) : .notProvided,
            hidden: community.hidden,
            onlyModeratorsCanPost: community.restrictedToMods
        )
    }
}

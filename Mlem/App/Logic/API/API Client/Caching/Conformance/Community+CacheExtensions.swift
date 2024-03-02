//
//  Community+CacheExtensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-02.
//

import Foundation

extension Community1: CacheIdentifiable {
    var cacheId: Int {
        var hasher: Hasher = .init()
        hasher.combine(actorId)
        return hasher.finalize()
    }
    
    func update(with community: ApiCommunity) {
        updatedDate = community.updated
        displayName = community.title
        description = community.description
        removed = community.removed
        deleted = community.deleted
        nsfw = community.nsfw
        avatar = community.icon
        banner = community.banner
        hidden = community.hidden
        onlyModeratorsCanPost = community.postingRestrictedToMods
    }
}

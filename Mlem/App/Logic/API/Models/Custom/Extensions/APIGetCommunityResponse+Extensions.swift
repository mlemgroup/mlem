//
//  ApiGetCommunityResponse+Extensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19.
//

import Foundation

extension ApiGetCommunityResponse: CacheIdentifiable, ActorIdentifiable, Identifiable {
    var cacheId: Int {
        var hasher: Hasher = .init()
        hasher.combine(actorId)
        return hasher.finalize()
    }

    var actorId: URL { communityView.community.actorId }
    var id: Int { communityView.community.id }
}

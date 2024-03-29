//
//  ApiCommunityView+Extensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19.
//

import Foundation

extension ApiCommunityView: ActorIdentifiable, CacheIdentifiable, Identifiable {
    var cacheId: Int { actorId.hashValue }

    var actorId: URL { community.actorId }
    var id: Int { community.id }
}

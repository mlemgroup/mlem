//
//  ApiCommunityView+Extensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19.
//

import Foundation

extension ApiCommunityView: ActorIdentifiable, CacheIdentifiable, Identifiable {
    public var cacheId: Int { id }

    public var actorId: ActorIdentifier { community.actorId }
    public var id: Int { community.id }
}

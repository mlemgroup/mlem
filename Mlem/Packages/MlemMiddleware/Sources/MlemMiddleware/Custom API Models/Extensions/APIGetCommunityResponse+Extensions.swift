//
//  ApiGetCommunityResponse+Extensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19.
//

import Foundation

extension ApiGetCommunityResponse: CacheIdentifiable, ActorIdentifiable, Identifiable {
    public var cacheId: Int { id }
    
    public var actorId: ActorIdentifier { communityView.community.actorId }
    public var id: Int { communityView.community.id }
}

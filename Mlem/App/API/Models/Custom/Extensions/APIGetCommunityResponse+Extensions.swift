//
//  ApiGetCommunityResponse+Extensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19.
//

import Foundation

extension ApiGetCommunityResponse: ActorIdentifiable, Identifiable {
    var actorId: URL { communityView.community.actorId }
    var id: Int { communityView.community.id }
}
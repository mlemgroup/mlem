//
//  APIGetCommunityResponse+Extensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19.
//

import Foundation

extension APIGetCommunityResponse: ActorIdentifiable, Identifiable {
    var actorId: URL { community_view.community.actorId }
    var id: Int { community_view.community.id }
}

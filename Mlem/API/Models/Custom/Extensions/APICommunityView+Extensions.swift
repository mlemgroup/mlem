//
//  APICommunityView+Extensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19.
//

import Foundation

extension APICommunityView: ActorIdentifiable, Identifiable {
    var actorId: URL { community.actorId }
    var id: Int { community.id }
}

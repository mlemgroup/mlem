//
//  APICommunity+Extensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19.
//

import Foundation

extension APICommunity: Identifiable, ActorIdentifiable {
    var actorId: URL { actor_id }
}

extension APICommunity: Comparable {
    static func < (lhs: APICommunity, rhs: APICommunity) -> Bool {
        let lhsFullCommunity = lhs.name + (lhs.actorId.host ?? "")
        let rhsFullCommunity = rhs.name + (rhs.actorId.host ?? "")
        return lhsFullCommunity < rhsFullCommunity
    }
}

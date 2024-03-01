//
//  ApiCommunity+Extensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19.
//

import Foundation

extension ApiCommunity: ActorIdentifiable, CacheIdentifiable, Identifiable {
    var cacheId: Int {
        var hasher: Hasher = .init()
        hasher.combine(actorId)
        return hasher.finalize()
    }
}

extension ApiCommunity: Comparable {
    static func < (lhs: ApiCommunity, rhs: ApiCommunity) -> Bool {
        let lhsFullCommunity = lhs.name + (lhs.actorId.host ?? "")
        let rhsFullCommunity = rhs.name + (rhs.actorId.host ?? "")
        return lhsFullCommunity < rhsFullCommunity
    }
}

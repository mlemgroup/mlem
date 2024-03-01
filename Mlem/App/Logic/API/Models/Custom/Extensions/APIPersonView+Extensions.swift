//
//  ApiPersonView+Extensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19.
//

import Foundation

extension ApiPersonView: ActorIdentifiable, CacheIdentifiable, Identifiable {
    var cacheId: Int {
        var hasher: Hasher = .init()
        hasher.combine(actorId)
        return hasher.finalize()
    }

    var id: Int { person.id }
    var actorId: URL { person.actorId }
}

//
//  ApiGetPersonDetailsResponse+Extensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19.
//

import Foundation

extension ApiGetPersonDetailsResponse: ActorIdentifiable, CacheIdentifiable, Identifiable {
    var cacheId: Int {
        var hasher: Hasher = .init()
        hasher.combine(actorId)
        return hasher.finalize()
    }
    var actorId: URL { personView.person.actorId }
    var id: Int { personView.person.id }
}

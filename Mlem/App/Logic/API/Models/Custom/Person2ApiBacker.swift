//
//  Person2ApiBacker.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19.
//

import Foundation

/// Protocol for API types that contain sufficient information to create a Person2
protocol Person2ApiBacker: ActorIdentifiable, CacheIdentifiable, Identifiable {
    var person: ApiPerson { get }
    var counts: ApiPersonAggregates { get }
}

extension Person2ApiBacker {
    var cacheId: Int {
        var hasher: Hasher = .init()
        hasher.combine(actorId)
        return hasher.finalize()
    }

    var id: Int { person.id }
    var actorId: URL { person.actorId }
}

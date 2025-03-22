//
//  Person2ApiBacker.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19.
//

import Foundation

/// Protocol for API types that contain sufficient information to create a Person2
public protocol Person2ApiBacker: ActorIdentifiable, CacheIdentifiable, Identifiable {
    var person: ApiPerson { get }
    var admin: Bool { get }
    
    var counts: ApiPersonAggregates { get }
}

public extension Person2ApiBacker {
    var cacheId: Int { id }

    var id: Int { person.id }
    var actorId: ActorIdentifier { person.actorId }
}

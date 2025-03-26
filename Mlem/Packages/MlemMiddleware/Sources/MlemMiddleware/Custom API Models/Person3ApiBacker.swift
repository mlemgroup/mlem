//
//  Person3ApiBacker.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-01.
//

import Foundation

// Protocol for types that contain sufficient information to create a Person3
public protocol Person3ApiBacker: ActorIdentifiable, CacheIdentifiable, Identifiable {
    var moderates: [ApiCommunityModeratorView] { get }
    var site: ApiSite? { get }
    var person2ApiBacker: any Person2ApiBacker { get }
}

public extension Person3ApiBacker {
    var cacheId: Int { id }
    
    var id: Int { person2ApiBacker.id }
    var actorId: ActorIdentifier { person2ApiBacker.actorId }
}

//
//  Person3ApiBacker.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-01.
//

import Foundation

public struct Person3Snapshot: CacheIdentifiable {
    // Won't change, but the corresponding models need to
    // be updated within the `update` method of Person3.
    let person: Person2Snapshot
    let site: Instance1Snapshot?
    
    // May change. If you add/remove items from this list,
    // remember to also amend the `update` method of Person3!
    let moderatedCommunities: [Community1Snapshot]
    
    public var cacheId: Int { person.cacheId }
}

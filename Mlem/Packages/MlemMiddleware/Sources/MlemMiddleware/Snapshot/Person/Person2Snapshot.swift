//
//  Person2ApiBacker.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19.
//

import Foundation

public struct Person2Snapshot: CacheIdentifiable {
    // Won't change, but the corresponding models need to
    // be updated within the `update` method of Person2.
    public let person: Person1Snapshot
    
    // May change. If you add/remove items from this list,
    // remember to also amend the `update` method of Person2!
    public let isAdmin: Bool
    public let postCount: Int
    public let commentCount: Int
    
    public var cacheId: Int { person.cacheId }
    
    public init(
        person: Person1Snapshot,
        isAdmin: Bool,
        postCount: Int,
        commentCount: Int
    ) {
        self.person = person
        self.isAdmin = isAdmin
        self.postCount = postCount
        self.commentCount = commentCount
    }
}

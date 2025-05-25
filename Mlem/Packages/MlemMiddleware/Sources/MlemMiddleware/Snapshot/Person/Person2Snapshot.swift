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
    
    init(from person: ApiPersonView) throws(ApiClientError) {
        self.person = try .init(from: person.person)
        
        self.isAdmin = person.isAdmin
        
        if let postCount = person.person.postCount ?? person.counts?.postCount {
            self.postCount = postCount
        } else {
            throw .responseMissingRequiredData("ApiPersonView postCount")
        }
        
        if let commentCount = person.person.commentCount ?? person.counts?.commentCount {
            self.commentCount = commentCount
        } else {
            throw .responseMissingRequiredData("ApiPersonView commentCount")
        }
    }
    
    init(from localUser: ApiLocalUserView) throws(ApiClientError) {
        self.person = try .init(from: localUser.person)
        self.isAdmin = localUser.localUser.admin
        
        if let postCount = localUser.person.postCount ?? localUser.counts?.postCount {
            self.postCount = postCount
        } else {
            throw .responseMissingRequiredData("ApiLocalUserView postCount")
        }
        
        if let commentCount = localUser.person.commentCount ?? localUser.counts?.commentCount {
            self.commentCount = commentCount
        } else {
            throw .responseMissingRequiredData("ApiLocalUserView commentCount")
        }
    }
}

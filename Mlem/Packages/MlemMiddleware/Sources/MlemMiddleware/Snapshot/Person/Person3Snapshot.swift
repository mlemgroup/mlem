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
    
    init(from userInfo: ApiMyUserInfo) throws(ApiClientError) {
        self.person = try .init(from: userInfo.localUserView)
        self.site = nil
        
        var moderatedCommunities: [Community1Snapshot] = []
        moderatedCommunities.reserveCapacity(userInfo.moderates.count)
        
        for moderate in userInfo.moderates {
            try moderatedCommunities.append(.init(from: moderate.community))
        }
        
        self.moderatedCommunities = moderatedCommunities
    }
    
    init(from personDetails: ApiGetPersonDetailsResponse) throws(ApiClientError) {
        self.person = try .init(from: personDetails.personView)
        
        if let site = personDetails.site {
            self.site = try .init(from: site)
        } else {
            self.site = nil
        }
        
        var moderatedCommunities: [Community1Snapshot] = []
        moderatedCommunities.reserveCapacity(personDetails.moderates.count)
        
        for moderate in personDetails.moderates {
            try moderatedCommunities.append(.init(from: moderate.community))
        }
        
        self.moderatedCommunities = moderatedCommunities
    }
}

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
    let site: ApiSite?
    
    // May change. If you add/remove items from this list,
    // remember to also amend the `update` method of Person3!
    let moderatedCommunities: [ApiCommunity]
    
    public var cacheId: Int { person.cacheId }
    
    init(from myUserInfo: ApiMyUserInfo) throws(ApiClientError) {
        self.person = try .init(from: myUserInfo.localUserView)
        self.site = nil
        self.moderatedCommunities = myUserInfo.moderates.map(\.community)
    }
    
    init(from personDetails: ApiGetPersonDetailsResponse) throws(ApiClientError) {
        self.person = try .init(from: personDetails.personView)
        self.site = personDetails.site
        self.moderatedCommunities = personDetails.moderates.map(\.community)
    }
}

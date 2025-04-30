//
//  Person3ApiBacker.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-01.
//

import Foundation

public struct Person3Backer: CacheIdentifiable {
    let person: Person2Backer
    let site: ApiSite?
    let moderates: [ApiCommunityModeratorView]
    
    public var cacheId: Int { person.cacheId }
    
    init(from myUserInfo: ApiMyUserInfo) {
        self.person = .init(from: myUserInfo.localUserView)
        self.site = myUserInfo.site
        self.moderates = myUserInfo.moderates
    }
    
    init(from personDetails: ApiGetPersonDetailsResponse) {
        self.person = .init(from: personDetails.personView)
        self.site = personDetails.site
        self.moderates = personDetails.moderates
    }
}

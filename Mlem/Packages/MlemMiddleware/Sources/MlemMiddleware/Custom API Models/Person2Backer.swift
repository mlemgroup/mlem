//
//  Person2ApiBacker.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19.
//

import Foundation

public struct Person2Backer: CacheIdentifiable {
    public let person: ApiPerson
    public let admin: Bool
    public let counts: ApiPersonAggregates
    
    public var cacheId: Int { person.cacheId }
    
    init(from person: ApiPersonView) {
        self.person = person.person
        self.admin = person.admin
        self.counts = person.counts ?? .zero
    }
    
    init(from localUser: ApiLocalUserView) {
        self.person = localUser.person
        self.admin = localUser.admin
        self.counts = localUser.counts ?? .zero
    }
}

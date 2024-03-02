//
//  UserCore3.swift
//  Mlem
//
//  Created by Sjmarf on 10/02/2024.
//

import SwiftUI

@Observable
final class Person3: Person3Providing, ContentModel {
    typealias ApiType = ApiGetPersonDetailsResponse
    var person3: Person3 { self }
    
    var source: ApiClient

    let person2: Person2

    var instance: Instance1!
    var moderatedCommunities: [Community1] = .init()
    
    var cacheId: Int {
        var hasher: Hasher = .init()
        hasher.combine(actorId)
        return hasher.finalize()
    }
  
    init(
        source: ApiClient,
        person2: Person2,
        instance: Instance1? = nil,
        moderatedCommunities: [Community1] = .init()
    ) {
        self.source = source
        self.person2 = person2
        self.instance = instance
        self.moderatedCommunities = moderatedCommunities
    }
    
    func update(moderatedCommunities: [Community1], person2ApiBacker: any Person2ApiBacker) {
        self.moderatedCommunities = moderatedCommunities
        person2.update(with: person2ApiBacker)
    }
}

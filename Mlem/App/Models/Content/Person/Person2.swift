//
//  UserCore2.swift
//  Mlem
//
//  Created by Sjmarf on 10/02/2024.
//

import SwiftUI

@Observable
final class Person2: Person2Providing, ContentModel {
    typealias ApiType = ApiPersonView
    var person2: Person2 { self }
    
    var api: ApiClient
    
    let person1: Person1
    
    var postCount: Int = 0
    var commentCount: Int = 0
    
    var cacheId: Int {
        var hasher: Hasher = .init()
        hasher.combine(actorId)
        return hasher.finalize()
    }
    
    init(
        api: ApiClient,
        person1: Person1,
        postCount: Int = 0,
        commentCount: Int = 0
    ) {
        self.api = api
        self.person1 = person1
        self.postCount = postCount
        self.commentCount = commentCount
    }
    
    func update(with apiType: any Person2ApiBacker) {
        postCount = apiType.counts.postCount
        commentCount = apiType.counts.commentCount
        person1.update(with: apiType.person)
    }
}

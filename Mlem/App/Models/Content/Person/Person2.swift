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
    
    var source: ApiClient
    
    let person1: Person1
    
    var postCount: Int = 0
    var commentCount: Int = 0
    
    var cacheId: Int {
        var hasher: Hasher = .init()
        hasher.combine(actorId)
        return hasher.finalize()
    }
    
    init(source: ApiClient, from personView: ApiPersonView) {
        self.source = source
        self.person1 = source.caches.person1.createModel(api: source, for: personView.person)
        update(with: personView)
    }
    
    init(source: ApiClient, from localUserView: ApiLocalUserView) {
        self.source = source
        self.person1 = source.caches.person1.createModel(api: source, for: localUserView.person)
        update(with: localUserView)
    }
    
    func update(with personView: ApiPersonView) {
        person1.update(with: personView.person)
    }
    
    func update(with personView: any ApiPersonViewLike) {
        postCount = personView.counts.postCount
        commentCount = personView.counts.commentCount
        person1.update(with: personView.person)
    }
}

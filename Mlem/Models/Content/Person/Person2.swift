//
//  UserCore2.swift
//  Mlem
//
//  Created by Sjmarf on 10/02/2024.
//

import SwiftUI

@Observable
final class Person2: Person2Providing, NewContentModel {
    typealias APIType = APIPersonView
    var person2: Person2 { self }
    
    var source: any APISource
    
    let person1: Person1
    
    var postCount: Int = 0
    var postScore: Int = 0
    var commentCount: Int = 0
    var commentScore: Int = 0
    
    init(source: any APISource, from personView: APIPersonView) {
        self.person1 = source.caches.person1.createModel(source: source, for: personView.person)
        self.update(with: personView)
    }
    
    init(source: any APISource, from localUserView: APILocalUserView) {
        self.person1 = source.caches.person1.createModel(source: source, for: localUserView.person)
        self.update(with: localUserView)
    }
    
    func update(with personView: APIPersonView) {
        person1.update(with: personView.person)
    }
    
    func update(with personView: any APIPersonViewLike) {
        self.postCount = personView.counts.postCount
        self.postScore = personView.counts.postScore ?? 0
        self.commentCount = personView.counts.commentCount
        self.commentScore = personView.counts.commentScore ?? 0
        self.user1.update(with: personView.person)
    }
}

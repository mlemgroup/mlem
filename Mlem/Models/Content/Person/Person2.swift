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
    var commentCount: Int = 0
    
    init(source: any APISource, from personView: APIPersonView) {
        self.source = source
        self.person1 = source.caches.person1.createModel(source: source, for: personView.person)
        update(with: personView)
    }
    
    init(source: any APISource, from localUserView: APILocalUserView) {
        self.source = source
        self.person1 = source.caches.person1.createModel(source: source, for: localUserView.person)
        update(with: localUserView)
    }
    
    func update(with personView: APIPersonView) {
        person1.update(with: personView.person)
    }
    
    func update(with personView: any APIPersonViewLike) {
        postCount = personView.counts.postCount
        commentCount = personView.counts.commentCount
        person1.update(with: personView.person)
    }
}

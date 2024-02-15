//
//  UserCore2.swift
//  Mlem
//
//  Created by Sjmarf on 10/02/2024.
//

import SwiftUI

@Observable
final class User2: User2Providing, NewContentModel {
    typealias APIType = APIPersonView
    var user2: User2 { self }
    
    var source: any APISource
    
    let user1: User1
    
    var postCount: Int = 0
    var postScore: Int = 0
    var commentCount: Int = 0
    var commentScore: Int = 0
    
    init(source: any APISource, from personView: APIPersonView) {
        self.user1 = source.caches.user1.createModel(source: source, for: personView.person)
        self.update(with: personView)
    }
    
    init(source: any APISource, from localUserView: APILocalUserView) {
        self.user1 = source.caches.user1.createModel(source: source, for: localUserView.person)
        self.update(with: localUserView)
    }
    
    func update(with personView: APIPersonView) {
        user1.update(with: personView.person)
    }
    
    func update(with personView: any APIPersonViewLike) {
        self.postCount = personView.counts.postCount
        self.postScore = personView.counts.postScore ?? 0
        self.commentCount = personView.counts.commentCount
        self.commentScore = personView.counts.commentScore ?? 0
        self.user1.update(with: personView.person)
    }
}

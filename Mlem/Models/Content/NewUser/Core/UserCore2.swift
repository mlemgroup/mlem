//
//  UserCore2.swift
//  Mlem
//
//  Created by Sjmarf on 10/02/2024.
//

import SwiftUI

@Observable
final class UserCore2: CoreModel {
    static var cache: CoreContentCache<UserCore2> = .init()
    typealias APIType = APIPersonView
    
    var actorId: URL { core1.actorId }
    
    let core1: UserCore1
    
    var postCount: Int
    var postScore: Int
    var commentCount: Int
    var commentScore: Int
    
    init(from personView: APIPersonView) {
        self.postCount = personView.counts.postCount
        self.postScore = personView.counts.postScore ?? 0
        self.commentCount = personView.counts.commentCount
        self.commentScore = personView.counts.commentScore ?? 0
        
        self.core1 = .create(from: personView.person)
    }
    
    func update(with personView: APIPersonView) {
        self.postCount = personView.counts.postCount
        self.postScore = personView.counts.postScore ?? 0
        self.commentCount = personView.counts.commentCount
        self.commentScore = personView.counts.commentScore ?? 0
    }
}

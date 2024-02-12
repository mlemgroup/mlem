//
//  UserCore2.swift
//  Mlem
//
//  Created by Sjmarf on 10/02/2024.
//

import SwiftUI

@Observable
final class UserCore2: CoreModel {
    typealias BaseEquivalent = User2
    static var cache: CoreContentCache<UserCore2> = .init()
    typealias APIType = APIPersonView
    
    var actorId: URL { core1.actorId }
    
    let core1: UserCore1
    
    var postCount: Int = 0
    var postScore: Int = 0
    var commentCount: Int = 0
    var commentScore: Int = 0
    
    init(from personView: APIPersonView) {
        self.core1 = .create(from: personView.person)
        self.update(with: personView, cascade: false)
    }
    
    func update(with personView: APIPersonView, cascade: Bool = true) {
        self.postCount = personView.counts.postCount
        self.postScore = personView.counts.postScore ?? 0
        self.commentCount = personView.counts.commentCount
        self.commentScore = personView.counts.commentScore ?? 0
        if cascade {
            self.core1.update(with: personView.person)
        }
    }
}

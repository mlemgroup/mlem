//
//  UserCore2.swift
//  Mlem
//
//  Created by Sjmarf on 10/02/2024.
//

import SwiftUI

protocol UserCore2Providing: UserCore1Providing {
    var postCount: Int { get }
    var postScore: Int { get }
    var commentCount: Int { get }
    var commentScore: Int { get }
}

@Observable
final class UserCore2: UserCore2Providing, UserCore {
    typealias BaseEquivalent = UserBase2
    static var cache: CoreContentCache<UserCore2> = .init()
    typealias APIType = APIPersonView
    
    let core1: UserCore1
    
    var postCount: Int = 0
    var postScore: Int = 0
    var commentCount: Int = 0
    var commentScore: Int = 0
    
    // Forwarded properties from UserCore1
    var actorId: URL { core1.actorId }
    var name: String { core1.name }
    var creationDate: Date { core1.creationDate }
    var updatedDate: Date? { core1.updatedDate }
    var displayName: String? { core1.displayName }
    var description: String? { core1.description }
    var matrixId: String? { core1.matrixId }
    var avatar: URL? { core1.avatar }
    var banner: URL? { core1.banner }
    var deleted: Bool { core1.deleted }
    var isBot: Bool { core1.isBot }
    
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
    
    var highestCachedTier: any UserCore1Providing {
        UserCore3.cache.retrieveModel(actorId: actorId) ?? self
    }
}

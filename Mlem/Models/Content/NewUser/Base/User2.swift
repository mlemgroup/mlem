//
//  User2.swift
//  Mlem
//
//  Created by Sjmarf on 11/02/2024.
//

import SwiftUI

protocol User2Providing: User1Providing {
    var postCount: Int { get }
    var postScore: Int { get }
    var commentCount: Int { get }
    var commentScore: Int { get }
}

@Observable
class User2: User2Providing, BaseModel {
    // Conformance
    typealias APIType = APIPersonView
    var sourceInstance: NewInstanceStub
    
    // Wrapped layers
    let core2: UserCore2
    let base1: User1
    
    // Forwarded properties from UserBase1
    var id: Int { base1.id }
    var ban: BanType? { base1.ban }
    var isAdmin: Bool { base1.isAdmin }
    
    var actorId: URL { base1.actorId }
    var name: String { base1.name }
    var creationDate: Date { base1.creationDate }
    var updatedDate: Date? { base1.updatedDate }
    var displayName: String? { base1.displayName }
    var description: String? { base1.description }
    var matrixId: String? { base1.matrixId }
    var avatar: URL? { base1.avatar }
    var banner: URL? { base1.banner }
    var deleted: Bool { base1.deleted }
    var isBot: Bool { base1.isBot }
    
    // Forwarded properties from UserCore2
    var postCount: Int { core2.postCount }
    var postScore: Int { core2.postScore }
    var commentCount: Int { core2.commentCount }
    var commentScore: Int { core2.commentScore }
    
    required init(sourceInstance: NewInstanceStub, from personView: APIPersonView) {
        self.sourceInstance = sourceInstance
        self.core2 = UserCore2(from: personView)
        self.base1 = sourceInstance.caches.user1.createModel(
            sourceInstance: sourceInstance,
            for: personView.person
        )
    }
    
    func update(with personView: APIPersonView, cascade: Bool = true) {
        if cascade {
            self.core2.update(with: personView, cascade: false)
            self.base1.update(with: personView.person)
        }
    }
}

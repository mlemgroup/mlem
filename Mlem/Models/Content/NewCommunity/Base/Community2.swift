//
//  Community2.swift
//  Mlem
//
//  Created by Sjmarf on 10/02/2024.
//

import Foundation

protocol Community2Providing: Community1Providing {
    var subscriberCount: Int { get }
    var postCount: Int { get }
    var commentCount: Int { get }
    var activeUserCount: ActiveUserCount { get }
}

@Observable
class Community2: Community2Providing, BaseModel {
    typealias APIType = APICommunityView
    
    // Conformance
    var sourceInstance: NewInstanceStub
    
    // Wrapped layers
    private let core2: CommunityCore2
    private let base1: Community1
    
    // Forwarded properties from Community1
    var id: Int { base1.id }
    
    // Forwarded properties from CommunityCore1
    var actorId: URL { core2.actorId }
    var name: String { core2.core1.name }
    var creationDate: Date { core2.core1.creationDate }
    var updatedDate: Date? { core2.core1.updatedDate }
    var displayName: String { core2.core1.displayName }
    var description: String? { core2.core1.description }
    var removed: Bool { core2.core1.removed }
    var deleted: Bool { core2.core1.deleted }
    var nsfw: Bool { core2.core1.nsfw }
    var avatar: URL? { core2.core1.avatar }
    var banner: URL? { core2.core1.banner }
    var hidden: Bool { core2.core1.hidden }
    var onlyModeratorsCanPost: Bool { core2.core1.onlyModeratorsCanPost }
    
    // Forwarded properties from CommunityCore2
    var subscriberCount: Int { core2.subscriberCount }
    var postCount: Int { core2.postCount }
    var commentCount: Int { core2.commentCount }
    var activeUserCount: ActiveUserCount { core2.activeUserCount }
    
    required init(sourceInstance: NewInstanceStub, from communityView: APICommunityView) {
        self.sourceInstance = sourceInstance
        self.core2 = CommunityCore2(from: communityView)
        self.base1 = sourceInstance.caches.community1.createModel(
            sourceInstance: sourceInstance,
            for: communityView.community
        )
    }
    
    func update(with communityView: APICommunityView) {
        self.core2.update(with: communityView)
        self.base1.update(with: communityView.community)
    }
    
    func highestCachedTier() -> any Community1Providing { self }
}

//
//  Community2.swift
//  Mlem
//
//  Created by Sjmarf on 10/02/2024.
//

import Foundation

protocol Community2Providing: Community1Providing, CommunityCore2Providing { }

@Observable
final class Community2: Community2Providing, BaseModel {
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
    var name: String { core2.name }
    var creationDate: Date { core2.creationDate }
    var updatedDate: Date? { core2.updatedDate }
    var displayName: String { core2.displayName }
    var description: String? { core2.description }
    var removed: Bool { core2.removed }
    var deleted: Bool { core2.deleted }
    var nsfw: Bool { core2.nsfw }
    var avatar: URL? { core2.avatar }
    var banner: URL? { core2.banner }
    var hidden: Bool { core2.hidden }
    var onlyModeratorsCanPost: Bool { core2.onlyModeratorsCanPost }
    
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
    
    func update(with communityView: APICommunityView, cascade: Bool = true) {
        if cascade {
            self.core2.update(with: communityView)
            self.base1.update(with: communityView.community)
        }
    }
    
    static func getCache(for sourceInstance: NewInstanceStub) -> BaseContentCache<Community2> {
        return sourceInstance.caches.community2
    }
}

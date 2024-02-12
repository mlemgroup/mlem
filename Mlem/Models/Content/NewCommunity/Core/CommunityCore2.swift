//
//  CommunityTier2.swift
//  Mlem
//
//  Created by Sjmarf on 03/02/2024.
//

import Dependencies
import Observation
import SwiftUI

protocol CommunityCore2Providing: CommunityCore1Providing {
    var subscriberCount: Int { get }
    var postCount: Int { get }
    var commentCount: Int { get }
    var activeUserCount: ActiveUserCount { get }
}

@Observable
final class CommunityCore2: CommunityCore2Providing, CommunityCore {
    typealias BaseEquivalent = CommunityBase2
    static var cache: CoreContentCache<CommunityCore2> = .init()
    typealias APIType = APICommunityView

    // Wrapped Layers
    let core1: CommunityCore1

    var subscriberCount: Int = 0
    var postCount: Int = 0
    var commentCount: Int = 0
    var activeUserCount: ActiveUserCount = .zero
    
    // Forwarded properties from CommunityCore1
    var actorId: URL { core1.actorId }
    var name: String { core1.name }
    var creationDate: Date { core1.creationDate }
    var updatedDate: Date? { core1.updatedDate }
    var displayName: String { core1.displayName }
    var description: String? { core1.description }
    var removed: Bool { core1.removed }
    var deleted: Bool { core1.deleted }
    var nsfw: Bool { core1.nsfw }
    var avatar: URL? { core1.avatar }
    var banner: URL? { core1.banner }
    var hidden: Bool { core1.hidden }
    var onlyModeratorsCanPost: Bool { core1.onlyModeratorsCanPost }

    required init(from communityView: APICommunityView) {
        self.core1 = CommunityCore1.cache.createModel(for: communityView.community)
        self.update(with: communityView, cascade: false)
    }
    
    func update(with communityView: APICommunityView, cascade: Bool = true) {
        subscriberCount = communityView.counts.subscribers
        postCount = communityView.counts.posts
        commentCount = communityView.counts.comments
        activeUserCount = .init(
            sixMonths: communityView.counts.usersActiveHalfYear,
            month: communityView.counts.usersActiveMonth,
            week: communityView.counts.usersActiveWeek,
            day: communityView.counts.usersActiveDay
        )
        if cascade {
            core1.update(with: communityView.community)
        }
    }
    
    var highestCachedTier: any CommunityCore1Providing {
        CommunityCore3.cache.retrieveModel(actorId: actorId) ?? self
    }
}

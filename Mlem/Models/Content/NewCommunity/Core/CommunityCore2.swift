//
//  CommunityTier2.swift
//  Mlem
//
//  Created by Sjmarf on 03/02/2024.
//

import Dependencies
import Observation
import SwiftUI

@Observable
final class CommunityCore2: CoreModel {
    static var cache: CoreContentCache<CommunityCore2> = .init()
    typealias APIType = APICommunityView
    
    var actorId: URL { core1.actorId }
    
    let core1: CommunityCore1

    var subscriberCount: Int
    var postCount: Int
    var commentCount: Int
    var activeUserCount: ActiveUserCount

    required init(from communityView: APICommunityView) {
        subscriberCount = communityView.counts.subscribers
        postCount = communityView.counts.posts
        commentCount = communityView.counts.comments
        activeUserCount = .init(
            sixMonths: communityView.counts.usersActiveHalfYear,
            month: communityView.counts.usersActiveMonth,
            week: communityView.counts.usersActiveWeek,
            day: communityView.counts.usersActiveDay
        )

        core1 = CommunityCore1.cache.createModel(for: communityView.community)
    }
    
    func update(with communityView: APICommunityView) {
        subscriberCount = communityView.counts.subscribers
        postCount = communityView.counts.posts
        commentCount = communityView.counts.comments
        activeUserCount = .init(
            sixMonths: communityView.counts.usersActiveHalfYear,
            month: communityView.counts.usersActiveMonth,
            week: communityView.counts.usersActiveWeek,
            day: communityView.counts.usersActiveDay
        )
        core1.update(with: communityView.community)
    }
}

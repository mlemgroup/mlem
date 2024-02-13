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
final class Community2: Community2Providing, NewContentModel {
    typealias APIType = APICommunityView
    var community2: Community2 { self }
    
    var source: any APISource

    let community1: Community1

    var subscriberCount: Int = 0
    var postCount: Int = 0
    var commentCount: Int = 0
    var activeUserCount: ActiveUserCount = .zero

    required init(source: any APISource, from communityView: APICommunityView) {
        self.source = source
        self.community1 = source.caches.community1.createModel(source: source, for: communityView.community)
        self.update(with: communityView)
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
        community1.update(with: communityView.community)
    }
}
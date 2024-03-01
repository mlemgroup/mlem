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
final class Community2: Community2Providing, ContentModel {
    typealias ApiType = ApiCommunityView
    var community2: Community2 { self }
    var source: ApiClient

    let community1: Community1
    
    var subscribed: Bool = false
    var favorited: Bool = false

    var subscriberCount: Int = 0
    var postCount: Int = 0
    var commentCount: Int = 0
    var activeUserCount: ActiveUserCount = .zero
    
    var cacheId: Int { community1.cacheId }

    required init(source: ApiClient, from communityView: ApiCommunityView) {
        self.source = source
        self.community1 = source.caches.community1.createModel(api: source, for: communityView.community)
        update(with: communityView)
    }
    
    func update(with communityView: ApiCommunityView) {
        subscribed = communityView.subscribed.isSubscribed
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

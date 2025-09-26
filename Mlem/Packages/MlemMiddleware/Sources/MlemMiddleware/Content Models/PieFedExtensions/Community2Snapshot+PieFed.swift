//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-19.
//

import Foundation

public extension Community2Snapshot {
    init(from community: PieFedCommunityView, allPropertiesPresent: Bool = false) throws(ApiClientError) {
        let subscription: SubscriptionModel = .init(
            total: community.counts.totalSubscriptionsCount,
            local: community.counts.subscriptionsCount,
            subscribed: community.subscribed.isSubscribed,
            pending: community.subscribed == .pending
        )
        
        let activeUserCount: ActiveUserCount = .init(
            sixMonths: community.counts.active6monthly ?? 0,
            month: community.counts.activeMonthly ?? 0,
            week: community.counts.activeWeekly ?? 0,
            day: community.counts.activeDaily ?? 0
        )
            
        try self.init(
            community: .init(from: community.community, allPropertiesPresent: allPropertiesPresent),
            subscription: subscription,
            postCount: community.counts.postCount,
            commentCount: community.counts.postReplyCount,
            activeUserCount: activeUserCount,
            bannedFromCommunity: false
        )
    }
}

//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-07-14.
//

import Foundation

extension Community2Snapshot {
    init(from community: LemmyCommunityView) throws(ApiClientError) {
        guard let totalSubscribers = community.community.subscribers ?? community.counts?.subscribers,
              let localSubscribers = community.community.subscribersLocal ?? community.counts?.subscribersLocal
        else {
            throw .responseMissingRequiredData("LemmyCommunityView subscriber count")
        }

        let subscribed: Bool
        if let subscribed_ = community.subscribed?.isSubscribed {
            subscribed = subscribed_
        } else {
            subscribed = community.communityActions?.followState?.isSubscribed ?? false
        }

        let subscription = SubscriptionModel(
            total: totalSubscribers,
            local: localSubscribers,
            subscribed: subscribed,
            pending: community.communityActions?.followState == .pending || community.subscribed == .pending
        )
        
        guard let postCount = community.counts?.posts ?? community.community.posts else {
            throw .responseMissingRequiredData("LemmyCommunityView postCount")
        }
        
        guard let commentCount = community.counts?.comments ?? community.community.comments else {
            throw .responseMissingRequiredData("LemmyCommunityView commentCount")
        }
        
        guard let activeUsers6Months = community.counts?.usersActiveHalfYear ?? community.community.usersActiveHalfYear,
              let activeUsersMonth = community.counts?.usersActiveMonth ?? community.community.usersActiveMonth,
              let activeUsersWeek = community.counts?.usersActiveWeek ?? community.community.usersActiveWeek,
              let activeUsersDay = community.counts?.usersActiveDay ?? community.community.usersActiveDay else {
            throw .responseMissingRequiredData("LemmyCommunityView activeUserCount")
        }

        let activeUserCount = ActiveUserCount(
            sixMonths: activeUsers6Months,
            month: activeUsersMonth,
            week: activeUsersWeek,
            day: activeUsersDay
        )
        
        let bannedFromCommunity: Bool?
        if let actions = community.communityActions {
            bannedFromCommunity = actions.banExpiresAt != nil
        } else {
            bannedFromCommunity = community.bannedFromCommunity
        }

        try self.init(
            community: .init(from: community.community),
            subscription: subscription,
            postCount: postCount,
            commentCount: commentCount,
            activeUserCount: activeUserCount,
            bannedFromCommunity: bannedFromCommunity
        )
    }
}

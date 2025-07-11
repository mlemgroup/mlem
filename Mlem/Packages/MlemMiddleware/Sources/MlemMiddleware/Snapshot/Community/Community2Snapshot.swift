//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-05-04.
//

import Foundation

public struct Community2Snapshot: CacheIdentifiable {
    // Won't change, but the corresponding models need to
    // be updated within the `update` method of Community2.
    public let community: Community1Snapshot
    
    // May change. If you add/remove items from this list,
    // remember to also amend the `update` method of Community2!
    public let subscription: SubscriptionModel
    public let postCount: Int
    public let commentCount: Int
    public let activeUserCount: ActiveUserCount
    public let bannedFromCommunity: Bool?
    
    public var cacheId: Int { community.cacheId }
    
    init(from community: LemmyCommunityView) throws(ApiClientError) {
        self.community = try .init(from: community.community)
        
        if let total = community.community.subscribers ?? community.counts?.subscribers,
           let subscribed = community.communityActions?.followState?.isSubscribed ?? community.subscribed?.isSubscribed {
            let local = community.community.subscribersLocal ?? community.counts?.subscribersLocal
            self.subscription = .init(
                total: total,
                local: local,
                subscribed: subscribed,
                pending: community.communityActions?.followState == .pending || community.subscribed == .pending
            )
        } else {
            throw .responseMissingRequiredData("LemmyCommunityView subscribed")
        }
        
        if let postCount = community.counts?.posts ?? community.community.posts {
            self.postCount = postCount
        } else {
            throw .responseMissingRequiredData("LemmyCommunityView postCount")
        }
        
        if let commentCount = community.counts?.comments ?? community.community.comments {
            self.commentCount = commentCount
        } else {
            throw .responseMissingRequiredData("LemmyCommunityView commentCount")
        }
        
        if let sixMonths = community.counts?.usersActiveHalfYear ?? community.community.usersActiveHalfYear,
           let month = community.counts?.usersActiveMonth ?? community.community.usersActiveMonth,
           let week = community.counts?.usersActiveWeek ?? community.community.usersActiveWeek,
           let day = community.counts?.usersActiveDay ?? community.community.usersActiveDay {
            self.activeUserCount = .init(
                sixMonths: sixMonths,
                month: month,
                week: week,
                day: day
            )
        } else {
            throw .responseMissingRequiredData("LemmyCommunityView activeUserCount")
        }
        
        if let actions = community.communityActions {
            self.bannedFromCommunity = actions.banExpiresAt != nil
        } else {
            self.bannedFromCommunity = community.bannedFromCommunity
        }
    }
}

//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-19.
//

import Foundation

public extension Community2Snapshot {
    init(from community: PieFedCommunityView) throws(ApiClientError) {
        self.community = try .init(from: community.community)
        self.subscription = .init(
            total: community.counts.subscriptionsCount,
            local: nil,
            subscribed: community.subscribed.isSubscribed,
            pending: community.subscribed == .pending
        )
        self.postCount = community.counts.postCount
        self.commentCount = community.counts.postReplyCount
        self.activeUserCount = .zero
        self.bannedFromCommunity = false
    }
}

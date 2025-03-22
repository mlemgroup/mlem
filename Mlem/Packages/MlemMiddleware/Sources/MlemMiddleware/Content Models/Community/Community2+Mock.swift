//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-02-03.
//  

import Foundation

#if DEBUG
public extension Community2 {
    static func mock(
        community1: Community1,
        subscriberCount: Int,
        localSubscriberCount: Int,
        subscribed: Bool,
        subscriptionPending: Bool,
        postCount: Int,
        commentCount: Int,
        activeUserCount: ActiveUserCount,
        bannedFromCommunity: Bool?
    ) -> Community2 {
        return .init(
            api: community1.api,
            community1: community1,
            subscription: .init(
                total: subscriberCount,
                local: localSubscriberCount,
                subscribed: subscribed,
                pending: subscriptionPending
            ),
            postCount: postCount,
            commentCount: commentCount,
            activeUserCount: activeUserCount,
            bannedFromCommunity: bannedFromCommunity
        )
    }
}
#endif

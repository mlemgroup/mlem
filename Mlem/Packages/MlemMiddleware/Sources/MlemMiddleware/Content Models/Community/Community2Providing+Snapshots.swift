//
//  Community2Providing+Snapshots.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2025-07-23.
//

extension Community2Providing {
    internal func takeSnapshot2() -> Community2Snapshot {
        .init(community: community1.takeSnapshot1(),
              subscription: .init(total: subscriberCount, local: localSubscriberCount, subscribed: subscribed, pending: false), // TODO: NOW pending?
              postCount: postCount,
              commentCount: commentCount,
              activeUserCount: activeUserCount,
              bannedFromCommunity: false) // TODO: NOW how to populate?
    }
}

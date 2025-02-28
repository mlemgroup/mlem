//
//  Community+Mock.swift
//  Mlem
//
//  Created by Sjmarf on 2025-02-03.
//

import Foundation
import MlemMiddleware

extension Community1 {
    static func mock(
        _ type: CommunityMockType,
        api: MockApiClient = .mock
    ) -> Community1 {
        .mock(
            api: api,
            actorId: type.actorId,
            id: type.id,
            name: type.name,
            created: type.created,
            instanceId: 0,
            updated: nil,
            displayName: type.displayName,
            description: type.description,
            removed: false,
            deleted: false,
            nsfw: false,
            avatar: type.avatar,
            banner: type.banner,
            hidden: false,
            onlyModeratorsCanPost: false,
            blocked: false,
            visibility: .public_
        )
    }
}

extension Community2 {
    static func mock(
        _ type: CommunityMockType,
        api: MockApiClient = .mock
    ) -> Community2 {
        .mock(
            community1: .mock(type, api: api),
            subscriberCount: type.subscriberCount,
            localSubscriberCount: type.localSubscriberCount,
            subscribed: false,
            subscriptionPending: false,
            postCount: type.postCount,
            commentCount: type.commentCount,
            activeUserCount: .init(sixMonths: 0, month: 0, week: 0, day: 0),
            bannedFromCommunity: nil
        )
    }
}

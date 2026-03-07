//
//  Community+Mock.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2026-02-17.
//

// TODO: updated mocks
//#if DEBUG
//    public extension Community1 {
//        static func mock(
//            api: MockApiClient = .mock,
//            actorId: ActorIdentifier? = nil,
//            id: Int,
//            name: String,
//            created: Date,
//            instanceId: Int,
//            updated: Date?,
//            displayName: String,
//            description: String?,
//            removed: Bool,
//            deleted: Bool,
//            nsfw: Bool,
//            avatar: URL?,
//            banner: URL?,
//            hidden: Bool,
//            onlyModeratorsCanPost: Bool,
//            blocked: Bool
//        ) -> Community1 {
//            .init(
//                api: api,
//                actorId: actorId ?? .init(url: URL(string: "https://\(api.host)/u/\(id)")!)!,
//                id: id,
//                name: name,
//                created: created,
//                instanceId: instanceId,
//                updated: updated,
//                displayName: displayName,
//                description: description,
//                removed: removed,
//                deleted: deleted,
//                nsfw: nsfw,
//                avatar: avatar,
//                banner: banner,
//                hidden: hidden,
//                onlyModeratorsCanPost: onlyModeratorsCanPost,
//                blocked: blocked
//            )
//        }
//    }
//#endif

//#if DEBUG
//    public extension Community2 {
//        static func mock(
//            community1: Community1,
//            subscriberCount: Int,
//            localSubscriberCount: Int,
//            subscribed: Bool,
//            subscriptionPending: Bool,
//            postCount: Int,
//            commentCount: Int,
//            activeUserCount: ActiveUserCount,
//            bannedFromCommunity: Bool?
//        ) -> Community2 {
//            .init(
//                api: community1.api,
//                community1: community1,
//                subscription: .init(
//                    total: subscriberCount,
//                    local: localSubscriberCount,
//                    subscribed: subscribed,
//                    pending: subscriptionPending
//                ),
//                postCount: postCount,
//                commentCount: commentCount,
//                activeUserCount: activeUserCount,
//                bannedFromCommunity: bannedFromCommunity
//            )
//        }
//    }
//#endif

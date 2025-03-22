//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-02-02.
//

import Foundation

#if DEBUG
    public extension Person1 {
        static func mock(
            api: MockApiClient = .mock,
            actorId: ActorIdentifier?,
            id: Int,
            name: String,
            created: Date,
            instanceId: Int,
            updated: Date?,
            displayName: String,
            description: String?,
            matrixId: String?,
            avatar: URL?,
            banner: URL?,
            deleted: Bool,
            isBot: Bool,
            instanceBan: InstanceBanType,
            blocked: Bool
        ) -> Person1 {
            .init(
                api: api,
                actorId: actorId ?? .init(url: URL(string: "https://\(api.host)/u/\(name)")!)!,
                id: id,
                name: name,
                created: created,
                instanceId: instanceId,
                updated: updated,
                displayName: displayName,
                description: description,
                matrixId: matrixId,
                avatar: avatar,
                banner: banner,
                deleted: deleted,
                isBot: isBot,
                instanceBan: instanceBan,
                blocked: blocked
            )
        }
    }
#endif

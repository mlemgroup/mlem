//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-02-03.
//

import Foundation

#if DEBUG
    public extension Community1 {
        static func mock(
            api: MockApiClient = .mock,
            actorId: ActorIdentifier? = nil,
            id: Int,
            name: String,
            created: Date,
            instanceId: Int,
            updated: Date?,
            displayName: String,
            description: String?,
            removed: Bool,
            deleted: Bool,
            nsfw: Bool,
            avatar: URL?,
            banner: URL?,
            hidden: Bool,
            onlyModeratorsCanPost: Bool,
            blocked: Bool,
            visibility: ApiCommunityVisibility?
        ) -> Community1 {
            .init(
                api: api,
                actorId: actorId ?? .init(url: URL(string: "https://\(api.host)/u/\(id)")!)!,
                id: id,
                name: name,
                created: created,
                instanceId: instanceId,
                updated: updated,
                displayName: displayName,
                description: description,
                removed: removed,
                deleted: deleted,
                nsfw: nsfw,
                avatar: avatar,
                banner: banner,
                hidden: hidden,
                onlyModeratorsCanPost: onlyModeratorsCanPost,
                blocked: blocked,
                visibility: visibility
            )
        }
    }
#endif

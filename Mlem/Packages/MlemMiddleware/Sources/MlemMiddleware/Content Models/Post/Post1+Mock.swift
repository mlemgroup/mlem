//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-02-02.
//

import Foundation

#if DEBUG
    public extension Post1 {
        static func mock(
            api: MockApiClient = .mock,
            actorId: ActorIdentifier? = nil,
            id: Int,
            creatorId: Int,
            communityId: Int,
            created: Date,
            title: String,
            content: String?,
            linkUrl: URL?,
            deleted: Bool,
            embed: PostEmbed?,
            pinnedCommunity: Bool,
            pinnedInstance: Bool,
            locked: Bool,
            nsfw: Bool,
            removed: Bool,
            thumbnailUrl: URL?,
            updated: Date?,
            languageId: Int,
            altText: String?
        ) -> Post1 {
            .init(
                api: api,
                actorId: actorId ?? .init(url: URL(string: "https://\(api.host)/post/\(id)")!)!,
                id: id,
                creatorId: creatorId,
                communityId: communityId,
                created: created,
                title: title,
                content: content,
                linkUrl: linkUrl,
                deleted: deleted,
                embed: embed,
                pinnedCommunity: pinnedCommunity,
                pinnedInstance: pinnedInstance,
                locked: locked,
                nsfw: nsfw,
                removed: removed,
                thumbnailUrl: thumbnailUrl,
                updated: updated,
                languageId: languageId,
                altText: altText
            )
        }
    }
#endif

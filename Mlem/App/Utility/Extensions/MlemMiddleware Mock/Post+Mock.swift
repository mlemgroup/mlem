//
//  Post1+Mock.swift
//  Mlem
//
//  Created by Sjmarf on 2025-02-02.
//

import Foundation
import MlemMiddleware

extension Post1 {
    static func mock(
        _ type: PostMockType,
        deleted: Bool = false,
        pinnedCommunity: Bool = false,
        pinnedInstance: Bool = false,
        locked: Bool = false,
        nsfw: Bool = false,
        removed: Bool = false
    ) -> Post1 {
        .mock(
            id: 0,
            creatorId: 0,
            communityId: 0,
            created: type.created,
            title: type.title,
            content: type.content,
            linkUrl: nil,
            deleted: deleted,
            embed: nil,
            pinnedCommunity: pinnedCommunity,
            pinnedInstance: pinnedInstance,
            locked: locked,
            nsfw: nsfw,
            removed: removed,
            thumbnailUrl: nil,
            updated: nil,
            languageId: 0,
            altText: nil
        )
    }
}

extension Post2 {
    static func mock(
        _ type: PostMockType
    ) -> Post2 {
        .mock(
            post1: .mock(type),
            creator: type.creator,
            community: type.community,
            votes: type.votes,
            creatorIsModerator: false,
            creatorIsAdmin: false,
            bannedFromCommunity: false,
            commentCount: type.commentCount,
            unreadCommentCount: 0,
            saved: false,
            read: false,
            hidden: false
        )
    }
}

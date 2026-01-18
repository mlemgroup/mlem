//
//  Post1+Mock.swift
//  Mlem
//
//  Created by Sjmarf on 2025-02-02.
//

import Foundation
import MlemMiddleware

// TODO: updated mocks
// extension Post1 {
//    static func mock(
//        _ type: PostMockType,
//        api: MockApiClient = .mock,
//        deleted: Bool = false,
//        pinnedCommunity: Bool = false,
//        pinnedInstance: Bool = false,
//        locked: Bool = false,
//        nsfw: Bool = false,
//        removed: Bool = false
//    ) -> Post1 {
//        .mock(
//            api: api,
//            id: type.id,
//            creatorId: 0,
//            communityId: 0,
//            created: type.created,
//            title: type.title,
//            content: type.content,
//            linkUrl: type.linkUrl,
//            deleted: deleted,
//            embed: nil,
//            pinnedCommunity: pinnedCommunity,
//            pinnedInstance: pinnedInstance,
//            locked: locked,
//            nsfw: nsfw,
//            removed: removed,
//            thumbnailUrl: nil,
//            updated: nil,
//            languageId: 0,
//            altText: nil
//        )
//    }
// }
//
// extension Post2 {
//    static func mock(
//        _ type: PostMockType,
//        api: MockApiClient = .mock
//    ) -> Post2 {
//        .mock(
//            api: api,
//            post1: .mock(type, api: api),
//            creator: .mock(type.creator, api: api),
//            community: .mock(type.community, api: api),
//            votes: type.votes,
//            creatorIsModerator: false,
//            creatorIsAdmin: false,
//            creatorBannedFromCommunity: false,
//            commentCount: type.commentCount,
//            unreadCommentCount: 0,
//            saved: false,
//            read: false,
//            hidden: false
//        )
//    }
// }

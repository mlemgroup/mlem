//
//  Comment+Mock.swift
//  Mlem
//
//  Created by Sjmarf on 2025-03-15.
//

// TODO: updated mocks
// import Foundation
// import MlemMiddleware
//
// extension Comment1 {
//    static func mock(
//        _ type: CommentMockType,
//        api: MockApiClient = .mock
//    ) -> Comment1 {
//        .mock(
//            api: api,
//            id: type.id,
//            content: type.content,
//            removed: false,
//            created: type.created,
//            updated: nil,
//            deleted: false,
//            creatorId: type.creator.id,
//            postId: type.post.id,
//            parentCommentIds: type.parentComments.map(\.id),
//            distinguished: false,
//            languageId: 0
//        )
//    }
// }
//
// extension Comment2 {
//    static func mock(
//        _ type: CommentMockType,
//        api: MockApiClient = .mock
//    ) -> Comment2 {
//        .mock(
//            api: api,
//            comment1: .mock(type, api: api),
//            creator: .mock(type.creator, api: api),
//            post: .mock(type.post, api: api),
//            community: .mock(type.post.community, api: api),
//            votes: type.votes,
//            saved: false,
//            creatorIsModerator: false,
//            creatorIsAdmin: false,
//            bannedFromCommunity: false,
//            commentCount: type.commentCount
//        )
//    }
// }

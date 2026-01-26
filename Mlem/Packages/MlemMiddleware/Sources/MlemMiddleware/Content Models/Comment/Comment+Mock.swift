//
//  Comment1+Mock.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-03-15.
//

import Foundation

// TODO: updated mocks
//#if DEBUG
//    public extension Comment1 {
//        static func mock(
//            api: MockApiClient = .mock,
//            actorId: ActorIdentifier? = nil,
//            id: Int,
//            content: String,
//            removed: Bool,
//            created: Date,
//            updated: Date?,
//            deleted: Bool,
//            creatorId: Int,
//            postId: Int,
//            parentCommentIds: [Int],
//            distinguished: Bool,
//            languageId: Int
//        ) -> Comment1 {
//            .init(
//                api: api,
//                actorId: actorId ?? .init(url: URL(string: "https://\(api.host)/comment/\(id)")!)!,
//                id: id,
//                content: content,
//                removed: removed,
//                created: created,
//                updated: updated,
//                deleted: deleted,
//                creatorId: creatorId,
//                postId: postId,
//                parentCommentIds: parentCommentIds,
//                distinguished: distinguished,
//                languageId: languageId
//            )
//        }
//    }
//#endif

//#if DEBUG
//    public extension Comment2 {
//        static func mock(
//            api: ApiClient,
//            comment1: Comment1,
//            creator: Person1,
//            post: UnifiedPostModel,
//            community: Community1,
//            votes: VotesModel,
//            saved: Bool,
//            creatorIsModerator: Bool,
//            creatorIsAdmin: Bool,
//            bannedFromCommunity: Bool,
//            commentCount: Int
//        ) -> Comment2 {
//            assert(api == comment1.api)
//            assert(api == creator.api)
//            assert(api == community.api)
//            assert(api == post.api)
//            return .init(
//                api: api,
//                comment1: comment1,
//                creator: creator,
//                post: post,
//                community: community,
//                votes: votes,
//                saved: saved,
//                creatorIsModerator: creatorIsModerator,
//                creatorIsAdmin: creatorIsAdmin,
//                creatorBannedFromCommunity: bannedFromCommunity,
//                commentCount: commentCount
//            )
//        }
//    }
//#endif

//extension Comment2 {
//    var apiCommentView: LemmyCommentView {
//        LemmyCommentView(
//            comment: comment1.apiComment,
//            creator: creator.apiPerson,
//            post: post.apiPost,
//            community: community.apiCommunity,
//            counts: .init(
//                commentId: id,
//                score: votes.total,
//                upvotes: votes.upvotes,
//                downvotes: votes.downvotes,
//                published: created,
//                childCount: commentCount
//            ),
//            creatorBannedFromCommunity: creator.isBannedFromCommunity(id: community.id) ?? false,
//            creatorIsModerator: creatorIsModerator,
//            creatorIsAdmin: creatorIsAdmin,
//            subscribed: .notSubscribed,
//            saved: saved,
//            creatorBlocked: creator.blocked,
//            myVote: votes.myVote.rawValue,
//            bannedFromCommunity: false,
//            communityActions: nil,
//            commentActions: nil,
//            personActions: nil,
//            postTags: nil,
//            canMod: nil,
//            creatorBanned: nil,
//            creatorBanExpiresAt: nil,
//            creatorCommunityBanExpiresAt: nil
//        )
//    }
//}

//
//  Comment2+Mock.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-03-15.
//

import Foundation

#if DEBUG
    public extension Comment2 {
        static func mock(
            api: ApiClient,
            comment1: Comment1,
            creator: Person1,
            post: Post1,
            community: Community1,
            votes: VotesModel,
            saved: Bool,
            creatorIsModerator: Bool,
            creatorIsAdmin: Bool,
            bannedFromCommunity: Bool,
            commentCount: Int
        ) -> Comment2 {
            assert(api == comment1.api)
            assert(api == creator.api)
            assert(api == community.api)
            assert(api == post.api)
            return .init(
                api: api,
                comment1: comment1,
                creator: creator,
                post: post,
                community: community,
                votes: votes,
                saved: saved,
                creatorIsModerator: creatorIsModerator,
                creatorIsAdmin: creatorIsAdmin,
                creatorBannedFromCommunity: bannedFromCommunity,
                commentCount: commentCount
            )
        }
    }
#endif

//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-02-04.
//

import Foundation

#if DEBUG
    public extension Post2 {
        static func mock(
            api: ApiClient = .mock,
            post1: Post1,
            creator: Person1,
            community: Community1,
            votes: VotesModel,
            creatorIsModerator: Bool?,
            creatorIsAdmin: Bool?,
            bannedFromCommunity: Bool,
            commentCount: Int,
            unreadCommentCount: Int,
            saved: Bool,
            read: Bool,
            hidden: Bool
        ) -> Post2 {
            assert(api === post1.api)
            assert(api === creator.api)
            assert(api === community.api)
            return .init(
                api: api,
                post1: post1,
                creator: creator,
                community: community,
                votes: votes,
                creatorIsModerator: creatorIsModerator,
                creatorIsAdmin: creatorIsAdmin,
                bannedFromCommunity: bannedFromCommunity,
                commentCount: commentCount,
                unreadCommentCount: unreadCommentCount,
                saved: saved,
                read: read,
                hidden: hidden
            )
        }
    }
#endif

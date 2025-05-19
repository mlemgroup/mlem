//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-03-17.
//

import Foundation

extension Comment2 {
    var apiCommentView: ApiCommentView {
        ApiCommentView(
            comment: comment1.apiComment,
            creator: creator.apiPerson,
            post: post.apiPost,
            community: community.apiCommunity,
            counts: .init(
                id: nil,
                commentId: id,
                score: votes.total,
                upvotes: votes.upvotes,
                downvotes: votes.downvotes,
                published: created,
                childCount: commentCount,
                hotRank: nil
            ),
            creatorBannedFromCommunity: bannedFromCommunity,
            subscribed: .notSubscribed,
            saved: saved,
            creatorBlocked: creator.blocked,
            myVote: votes.myVote.rawValue,
            creatorIsModerator: creatorIsModerator,
            creatorIsAdmin: creatorIsAdmin,
            bannedFromCommunity: false,
            communityActions: nil,
            commentActions: nil,
            personActions: nil,
            instanceActions: nil,
            creatorCommunityActions: nil,
            canMod: nil
        )
    }
}

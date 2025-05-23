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
                commentId: id,
                score: votes.total,
                upvotes: votes.upvotes,
                downvotes: votes.downvotes,
                published: created,
                childCount: commentCount
            ),
            creatorBannedFromCommunity: creator.isBannedFromCommunity(id: community.id) ?? false,
            creatorIsModerator: creatorIsModerator,
            creatorIsAdmin: creatorIsAdmin,
            subscribed: .notSubscribed,
            saved: saved,
            creatorBlocked: creator.blocked,
            myVote: votes.myVote.rawValue,
            bannedFromCommunity: false,
            communityActions: nil,
            commentActions: nil,
            personActions: nil,
            instanceActions: nil,
            creatorHomeInstanceActions: nil,
            creatorLocalInstanceActions: nil,
            creatorCommunityActions: nil,
            postTags: nil,
            canMod: nil,
            creatorBanned: nil
        )
    }
}

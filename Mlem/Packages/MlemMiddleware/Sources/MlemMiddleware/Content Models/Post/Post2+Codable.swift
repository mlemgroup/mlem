//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-02-23.
//

import Foundation

extension Post2 {
    var apiPostView: ApiPostView {
        ApiPostView(
            post: post1.apiPost,
            creator: creator.apiPerson,
            community: community.apiCommunity,
            creatorBannedFromCommunity: creator.isBannedFromCommunity(id: communityId) ?? false,
            creatorIsModerator: creatorIsModerator,
            creatorIsAdmin: creatorIsAdmin,
            counts: .init(
                postId: post1.id,
                comments: commentCount,
                score: votes.total,
                upvotes: votes.upvotes,
                downvotes: votes.downvotes,
                published: created,
                newestCommentTime: nil
            ),
            subscribed: .notSubscribed,
            saved: saved,
            read: read,
            creatorBlocked: creator.blocked,
            myVote: votes.myVote.rawValue,
            unreadComments: unreadCommentCount,
            bannedFromCommunity: bannedFromCommunity,
            hidden: hidden,
            imageDetails: nil,
            communityActions: nil,
            personActions: nil,
            postActions: nil,
            instanceActions: nil,
            creatorHomeInstanceActions: nil,
            creatorLocalInstanceActions: nil,
            creatorCommunityActions: nil,
            tags: nil,
            canMod: nil,
            creatorBanned: nil
        )
    }
}

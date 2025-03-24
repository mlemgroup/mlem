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
            counts: .init(
                id: nil,
                postId: post1.id,
                comments: commentCount,
                score: votes.total,
                upvotes: votes.upvotes,
                downvotes: votes.downvotes,
                published: created,
                newestCommentTimeNecro: nil,
                newestCommentTime: nil,
                featuredCommunity: pinnedCommunity,
                featuredLocal: pinnedInstance,
                hotRank: nil,
                hotRankActive: nil,
                reportCount: nil,
                unresolvedReportCount: nil
            ),
            subscribed: .notSubscribed,
            saved: saved,
            read: read,
            creatorBlocked: creator.blocked,
            myVote: votes.myVote.rawValue,
            unreadComments: unreadCommentCount,
            creatorIsModerator: creatorIsModerator,
            creatorIsAdmin: creatorIsAdmin,
            bannedFromCommunity: bannedFromCommunity,
            hidden: hidden,
            imageDetails: nil,
            tags: nil,
            canMod: nil
        )
    }
}

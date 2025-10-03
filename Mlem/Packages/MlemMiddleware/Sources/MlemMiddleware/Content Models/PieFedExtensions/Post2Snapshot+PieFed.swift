//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-19.
//

import Foundation

public extension Post2Snapshot {
    init(from post: PieFedPostView, overrideRead: Bool? = nil) throws(ApiClientError) {
        let votes = VotesModel(
            upvotes: post.counts.upvotes,
            downvotes: post.counts.downvotes,
            myVote: .guaranteedInit(from: post.myVote)
        )

        try self.init(
            post: .init(from: post.post),
            creator: .init(from: post.creator),
            community: .init(from: post.community),
            commentCount: post.counts.comments,
            unreadCommentCount: 0,
            creatorIsModerator: post.creatorIsModerator,
            creatorIsAdmin: post.creatorIsAdmin,
            creatorBannedFromCommunity: post.creatorBannedFromCommunity,
            creatorBlocked: false,
            votes: votes,
            saved: post.saved,
            read: overrideRead ?? post.read,
            hidden: post.hidden
        )
    }
    
    init(from report: PieFedPostReportView) throws(ApiClientError) {
        let votes = VotesModel(from: report.counts, myVote: .guaranteedInit(from: report.myVote))

        try self.init(
            post: .init(from: report.post),
            creator: .init(from: report.creator),
            community: .init(from: report.community),
            commentCount: report.counts.comments,
            unreadCommentCount: 0,
            creatorIsModerator: report.creatorIsModerator,
            creatorIsAdmin: report.creatorIsAdmin,
            creatorBannedFromCommunity: report.creatorBannedFromCommunity,
            creatorBlocked: report.creatorBlocked,
            votes: votes,
            saved: report.saved,
            read: false,
            hidden: false
        )
    }
}

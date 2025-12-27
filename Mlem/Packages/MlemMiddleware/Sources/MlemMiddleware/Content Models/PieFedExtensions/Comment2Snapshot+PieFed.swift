//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-19.
//

import Foundation

public extension Comment2Snapshot {
    init(from comment: PieFedCommentView) throws(ApiClientError) {
        let votes: VotesModel = .init(
            upvotes: comment.counts.upvotes,
            downvotes: comment.counts.downvotes,
            myVote: .guaranteedInit(from: comment.myVote)
        )

        try self.init(
            comment: .init(from: comment.comment),
            creator: .init(from: comment.creator),
            post: .init(from: comment.post),
            community: .init(from: comment.community),
            commentCount: comment.counts.childCount,
            creatorIsModerator: comment.creatorIsModerator,
            creatorIsAdmin: comment.creatorIsAdmin,
            creatorBannedFromCommunity: comment.creatorBannedFromCommunity,
            votes: votes,
            saved: comment.saved
        )
    }
    
    init(from report: PieFedCommentReportView) throws(ApiClientError) {
        let votes: VotesModel = .init(
            from: report.counts,
            myVote: .guaranteedInit(from: report.myVote)
        )

        try self.init(
            comment: .init(from: report.comment),
            creator: .init(from: report.commentCreator),
            post: .init(from: report.post),
            community: .init(from: report.community),
            commentCount: report.counts.childCount,
            creatorIsModerator: report.creatorIsModerator,
            creatorIsAdmin: report.creatorIsAdmin,
            creatorBannedFromCommunity: report.creatorBannedFromCommunity,
            votes: votes,
            saved: report.saved
        )
    }

    init(from reply: PieFedCommentReplyView) throws(ApiClientError) {
        let votes: VotesModel = .init(
            from: reply.counts,
            myVote: .guaranteedInit(from: reply.myVote)
        )

        try self.init(
            comment: .init(from: reply.comment),
            creator: .init(from: reply.creator),
            post: .init(from: reply.post),
            community: .init(from: reply.community),
            commentCount: reply.counts.childCount,
            creatorIsModerator: reply.creatorIsModerator,
            creatorIsAdmin: reply.creatorIsAdmin,
            creatorBannedFromCommunity: reply.creatorBannedFromCommunity,
            votes: votes,
            saved: reply.saved
        )
    }
}

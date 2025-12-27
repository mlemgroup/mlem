//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-07-14.
//

import Foundation

extension Comment2Snapshot {
    init(from comment: LemmyCommentView) throws(ApiClientError) {
        guard let commentCount = comment.comment.childCount ?? comment.counts?.childCount else {
            throw .responseMissingRequiredData("LemmyCommentView childCount")
        }

        let saved: Bool
        if let saved_ = comment.saved {
            saved = saved_
        } else {
            saved = comment.commentActions?.savedAt != nil
        }
        
        let votes: VotesModel
        if let counts = comment.counts {
            votes = .init(from: counts, myVote: .guaranteedInit(from: comment.myVote))
        } else if let upvotes = comment.comment.upvotes, let downvotes = comment.comment.downvotes {
            votes = .init(
                upvotes: upvotes,
                downvotes: downvotes,
                myVote: .init(comment.commentActions?.voteIsUpvote)
            )
        } else {
            throw .responseMissingRequiredData("LemmyCommentView score")
        }

        try self.init(
            comment: .init(from: comment.comment),
            creator: .init(from: comment.creator),
            post: .init(from: comment.post),
            community: .init(from: comment.community),
            commentCount: commentCount,
            creatorIsModerator: comment.creatorIsModerator,
            creatorIsAdmin: comment.creatorIsAdmin,
            creatorBannedFromCommunity: comment.creatorBannedFromCommunity,
            votes: votes,
            saved: saved
        )
    }
    
    init(from report: LemmyCommentReportView) throws(ApiClientError) {
        guard let commentCount = report.comment.childCount ?? report.counts?.childCount else {
            throw .responseMissingRequiredData("LemmyCommentReportView childCount")
        }

        let saved: Bool
        if let saved_ = report.saved {
            saved = saved_
        } else {
            saved = report.commentActions?.savedAt != nil
        }
        
        let votes: VotesModel
        if let counts = report.counts {
            votes = .init(from: counts, myVote: .guaranteedInit(from: report.myVote))
        } else if let upvotes = report.comment.upvotes, let downvotes = report.comment.downvotes {
            votes = .init(
                upvotes: upvotes,
                downvotes: downvotes,
                myVote: .init(report.commentActions?.voteIsUpvote)
            )
        } else {
            throw .responseMissingRequiredData("LemmyCommentReportView score")
        }

        try self.init(
            comment: .init(from: report.comment),
            creator: .init(from: report.commentCreator),
            post: .init(from: report.post),
            community: .init(from: report.community),
            commentCount: commentCount,
            creatorIsModerator: report.creatorIsModerator ?? false,
            creatorIsAdmin: report.creatorIsAdmin ?? false,
            creatorBannedFromCommunity: report.creatorBannedFromCommunity,
            votes: votes,
            saved: saved
        )
    }

    init(from reply: LemmyCommentReplyView) throws(ApiClientError) {
        try self.init(
            comment: .init(from: reply.comment),
            creator: .init(from: reply.creator),
            post: .init(from: reply.post),
            community: .init(from: reply.community),
            commentCount: reply.comment.childCount ?? reply.counts.childCount,
            creatorIsModerator: reply.creatorIsModerator,
            creatorIsAdmin: reply.creatorIsAdmin,
            creatorBannedFromCommunity: reply.creatorBannedFromCommunity,
            votes: .init(from: reply.counts, myVote: .guaranteedInit(from: reply.myVote)),
            saved: reply.saved
        )
    }

    init(from mention: LemmyPersonCommentMentionView) throws(ApiClientError) {
        try self.init(
            comment: .init(from: mention.comment),
            creator: .init(from: mention.creator),
            post: .init(from: mention.post),
            community: .init(from: mention.community),
            commentCount: mention.comment.childCount ?? mention.counts.childCount,
            creatorIsModerator: mention.creatorIsModerator,
            creatorIsAdmin: mention.creatorIsAdmin,
            creatorBannedFromCommunity: mention.creatorBannedFromCommunity,
            votes: .init(from: mention.counts, myVote: .guaranteedInit(from: mention.myVote)),
            saved: mention.saved
        )
    }
}

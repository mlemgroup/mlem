//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-07-14.
//

import Foundation

extension Post2Snapshot {
    /// Instantiates a Post2Snapshot from a given LemmyPostView
    /// - Parameters:
    ///   - post: LemmyPostView
    ///   - overrideRead: if present, overrides the LemmyPostView's read value. This is required because Lemmy doesn't return `read: true` in some cases (e.g., save post) even if the value is updated server-side.
    init(from post: LemmyPostView, overrideRead: Bool? = nil) throws(ApiClientError) {
        let votes: VotesModel
        if let counts = post.counts {
            votes = .init(from: counts, myVote: .guaranteedInit(from: post.myVote))
        } else if let upvotes = post.post.upvotes, let downvotes = post.post.downvotes {
            votes = .init(upvotes: upvotes, downvotes: downvotes, myVote: .guaranteedInit(from: post.postActions?.likeScore))
        } else {
            throw .responseMissingRequiredData("LemmyPostView scores")
        }
        
        let creatorBlocked: Bool
        if let personActions = post.personActions {
            creatorBlocked = personActions.blockedAt != nil
        } else if let creatorBlocked_ = post.creatorBlocked {
            creatorBlocked = creatorBlocked_
        } else {
            // `personActions` is `nil` on Lemmy 1.0 for your own posts.
            // Therefore we can set `creatorBlocked` to `false`.
            creatorBlocked = false
        }

        let commentCount: Int
        let unreadCommentCount: Int
        if let actions = post.postActions, let comments = post.post.comments {
            commentCount = comments
            unreadCommentCount = comments - (actions.readCommentsAmount ?? 0)
        } else if let counts = post.counts, let unreadComments = post.unreadComments {
            commentCount = counts.comments
            unreadCommentCount = unreadComments
        } else {
            throw .responseMissingRequiredData("LemmyPostView commentCount")
        }

        let saved: Bool
        let read: Bool
        let hidden: Bool
        if let actions = post.postActions {
            saved = actions.savedAt != nil
            read = overrideRead ?? (actions.readAt != nil)
            hidden = actions.hiddenAt != nil
        } else if let saved_ = post.saved, let read_ = post.read, let hidden_ = post.hidden {
            saved = saved_
            read = overrideRead ?? read_
            hidden = hidden_
        } else {
            throw .responseMissingRequiredData("LemmyPostView actions")
        }

        try self.init(
            post: .init(from: post.post),
            creator: .init(from: post.creator),
            community: .init(from: post.community),
            commentCount: commentCount,
            unreadCommentCount: unreadCommentCount,
            creatorIsModerator: post.creatorIsModerator,
            creatorIsAdmin: post.creatorIsAdmin,
            creatorBannedFromCommunity: post.creatorBannedFromCommunity,
            creatorBlocked: creatorBlocked,
            votes: votes,
            saved: saved,
            read: read,
            hidden: hidden
        )
    }
    
    init(from report: LemmyPostReportView) throws(ApiClientError) {
        let votes: VotesModel
        if let counts = report.counts {
            votes = .init(from: counts, myVote: .guaranteedInit(from: report.myVote))
        } else if let upvotes = report.post.upvotes, let downvotes = report.post.downvotes {
            votes = .init(upvotes: upvotes, downvotes: downvotes, myVote: .guaranteedInit(from: report.postActions?.likeScore))
        } else {
            throw .responseMissingRequiredData("LemmyPostReportView scores")
        }
        
        guard let creatorBlocked = report.creatorBlocked else {
            throw .responseMissingRequiredData("LemmyPostReportView creatorBlocked")
        }
        
        let commentCount: Int
        let unreadCommentCount: Int
        if let actions = report.postActions, let comments = report.post.comments {
            commentCount = comments
            unreadCommentCount = comments - (actions.readCommentsAmount ?? 0)
        } else if let counts = report.counts, let unreadComments = report.unreadComments {
            commentCount = counts.comments
            unreadCommentCount = unreadComments
        } else {
            throw .responseMissingRequiredData("LemmyPostReportView commentCount")
        }

        let saved: Bool
        let read: Bool
        let hidden: Bool
        if let actions = report.postActions {
            saved = actions.savedAt != nil
            read = actions.readAt != nil
            hidden = actions.hiddenAt != nil
        } else if let saved_ = report.saved, let read_ = report.read, let hidden_ = report.hidden {
            saved = saved_
            read = read_
            hidden = hidden_
        } else {
            throw .responseMissingRequiredData("LemmyPostReportView actions")
        }

        try self.init(
            post: .init(from: report.post),
            creator: .init(from: report.creator),
            community: .init(from: report.community),
            commentCount: commentCount,
            unreadCommentCount: unreadCommentCount,
            creatorIsModerator: report.creatorIsModerator ?? false,
            creatorIsAdmin: report.creatorIsAdmin ?? false,
            creatorBannedFromCommunity: report.creatorBannedFromCommunity,
            creatorBlocked: creatorBlocked,
            votes: votes,
            saved: saved,
            read: read,
            hidden: hidden
        )
    }
}

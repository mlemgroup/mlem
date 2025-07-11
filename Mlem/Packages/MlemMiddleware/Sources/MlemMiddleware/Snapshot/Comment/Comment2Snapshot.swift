//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-05-07.
//

import Foundation

public struct Comment2Snapshot: CacheIdentifiable {
    // Won't change, but the corresponding models need to
    // be updated within the `update` method of Post2.
    public let comment: Comment1Snapshot
    public let creator: Person1Snapshot
    public let post: Post1Snapshot
    public let community: Community1Snapshot
    
    // May change. If you add/remove items from this list,
    // remember to also amend the `update` method of Comment2!
    public let commentCount: Int
    public let creatorIsModerator: Bool
    public let creatorIsAdmin: Bool
    public let creatorBannedFromCommunity: Bool
    public let votes: VotesModel
    public let saved: Bool
    
    public var cacheId: Int { comment.cacheId }
    
    public init(from comment: LemmyCommentView) throws(ApiClientError) {
        self.comment = try .init(from: comment.comment)
        self.creator = try .init(from: comment.creator)
        self.post = try .init(from: comment.post)
        self.community = try .init(from: comment.community)
        
        if let childCount = comment.comment.childCount ?? comment.counts?.childCount {
            self.commentCount = childCount
        } else {
            throw .responseMissingRequiredData("LemmyCommentView childCount")
        }
            
        self.creatorIsAdmin = comment.creatorIsAdmin

        self.creatorIsModerator = comment.creatorIsModerator
        self.creatorBannedFromCommunity = comment.creatorBannedFromCommunity
        
        if let actions = comment.commentActions {
            self.saved = actions.savedAt != nil
        } else if let saved = comment.saved {
            self.saved = saved
        } else {
            throw .responseMissingRequiredData("LemmyCommentView saved")
        }
        
        if let counts = comment.counts {
            self.votes = .init(from: counts, myVote: .guaranteedInit(from: comment.myVote))
        } else if let upvotes = comment.comment.upvotes, let downvotes = comment.comment.downvotes {
            self.votes = .init(upvotes: upvotes, downvotes: downvotes, myVote: .guaranteedInit(from: comment.commentActions?.likeScore))
        } else {
            throw .responseMissingRequiredData("LemmyCommentView score")
        }
    }
    
    public init(from report: LemmyCommentReportView) throws(ApiClientError) {
        self.comment = try .init(from: report.comment)
        self.creator = try .init(from: report.commentCreator)
        self.post = try .init(from: report.post)
        self.community = try .init(from: report.community)
        
        if let childCount = report.comment.childCount ?? report.counts?.childCount {
            self.commentCount = childCount
        } else {
            throw .responseMissingRequiredData("LemmyCommentReportView childCount")
        }
            
        if let creatorIsAdmin = report.creatorIsAdmin {
            self.creatorIsAdmin = creatorIsAdmin
        } else {
            throw .responseMissingRequiredData("LemmyCommentReportView creatorIsAdmin")
        }

        // I reckon this value being removed in 1.0.0 is an oversight,
        // so am null coalescing to `false` for now.
        // https://github.com/LemmyNet/lemmy/pull/5808#discussion_r2198777728
        self.creatorIsModerator = report.creatorIsModerator ?? false
        
        self.creatorBannedFromCommunity = report.creatorBannedFromCommunity ?? false
        
        if let actions = report.commentActions {
            self.saved = actions.savedAt != nil
        } else if let saved = report.saved {
            self.saved = saved
        } else {
            throw .responseMissingRequiredData("LemmyCommentReportView saved")
        }
        
        if let counts = report.counts {
            self.votes = .init(from: counts, myVote: .guaranteedInit(from: report.myVote))
        } else if let upvotes = report.comment.upvotes, let downvotes = report.comment.downvotes {
            self.votes = .init(upvotes: upvotes, downvotes: downvotes, myVote: .guaranteedInit(from: report.commentActions?.likeScore))
        } else {
            throw .responseMissingRequiredData("LemmyCommentReportView score")
        }
    }
}

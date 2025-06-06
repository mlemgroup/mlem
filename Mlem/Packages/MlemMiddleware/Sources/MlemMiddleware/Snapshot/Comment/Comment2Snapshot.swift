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
    public let creatorIsModerator: Bool?
    public let creatorIsAdmin: Bool
    public let creatorBannedFromCommunity: Bool
    public let votes: VotesModel
    public let saved: Bool
    
    public var cacheId: Int { comment.cacheId }
    
    public init(from comment: ApiCommentView) throws(ApiClientError) {
        self.comment = try .init(from: comment.comment)
        self.creator = try .init(from: comment.commentCreator)
        self.post = try .init(from: comment.post)
        self.community = try .init(from: comment.community)
        
        if let childCount = comment.comment.childCount ?? comment.counts?.childCount {
            self.commentCount = childCount
        } else {
            throw .responseMissingRequiredData("ApiCommentView childCount")
        }
            
        self.creatorIsAdmin = comment.creatorIsAdmin

        if let actions = comment.creatorCommunityActions {
            self.creatorIsModerator = actions.becameModerator != nil
            self.creatorBannedFromCommunity = actions.banExpires != nil
        } else {
            self.creatorIsModerator = comment.creatorIsModerator
            self.creatorBannedFromCommunity = comment.creatorBannedFromCommunity ?? false
        }
        
        if let actions = comment.commentActions {
            self.saved = actions.saved != nil
        } else if let saved = comment.saved {
            self.saved = saved
        } else {
            throw .responseMissingRequiredData("ApiCommentView saved")
        }
        
        if let counts = comment.counts {
            self.votes = .init(from: counts, myVote: .guaranteedInit(from: comment.myVote))
        } else if let upvotes = comment.comment.upvotes, let downvotes = comment.comment.downvotes {
            self.votes = .init(upvotes: upvotes, downvotes: downvotes, myVote: .guaranteedInit(from: comment.commentActions?.likeScore))
        } else {
            throw .responseMissingRequiredData("ApiCommentView score")
        }
    }
    
    public init(from report: ApiCommentReportView) throws(ApiClientError) {
        self.comment = try .init(from: report.comment)
        self.creator = try .init(from: report.creator)
        self.post = try .init(from: report.post)
        self.community = try .init(from: report.community)
        
        if let childCount = report.comment.childCount ?? report.counts?.childCount {
            self.commentCount = childCount
        } else {
            throw .responseMissingRequiredData("ApiCommentReportView childCount")
        }
            
        if let creatorIsAdmin = report.creatorIsAdmin {
            self.creatorIsAdmin = creatorIsAdmin
        } else {
            throw .responseMissingRequiredData("ApiCommentReportView creatorIsAdmin")
        }

        if let actions = report.creatorCommunityActions {
            self.creatorIsModerator = actions.becameModerator != nil
            self.creatorBannedFromCommunity = actions.banExpires != nil
        } else {
            self.creatorIsModerator = report.creatorIsModerator
            self.creatorBannedFromCommunity = report.creatorBannedFromCommunity ?? false
        }
        
        if let actions = report.commentActions {
            self.saved = actions.saved != nil
        } else if let saved = report.saved {
            self.saved = saved
        } else {
            throw .responseMissingRequiredData("ApiCommentReportView saved")
        }
        
        if let counts = report.counts {
            self.votes = .init(from: counts, myVote: .guaranteedInit(from: report.myVote))
        } else if let upvotes = report.comment.upvotes, let downvotes = report.comment.downvotes {
            self.votes = .init(upvotes: upvotes, downvotes: downvotes, myVote: .guaranteedInit(from: report.commentActions?.likeScore))
        } else {
            throw .responseMissingRequiredData("ApiCommentReportView score")
        }
    }
}

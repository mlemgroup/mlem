//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-05-06.
//

import Foundation

public struct Post2Snapshot: CacheIdentifiable {
    // Won't change, but the corresponding models need to
    // be updated within the `update` method of Post2.
    public let post: Post1Snapshot
    public let creator: Person1Snapshot
    public let community: Community1Snapshot
    
    // May change. If you add/remove items from this list,
    // remember to also amend the `update` method of Post2!
    public let commentCount: Int
    public let unreadCommentCount: Int
    public let creatorIsModerator: Bool?
    public let creatorIsAdmin: Bool
    public let creatorBannedFromCommunity: Bool
    public let creatorBlocked: Bool
    public let votes: VotesModel
    public let saved: Bool
    public let read: Bool
    public let hidden: Bool
    
    public var cacheId: Int { post.cacheId }
    
    init(from post: LemmyPostView) throws(ApiClientError) {
        self.post = try .init(from: post.post)
        self.creator = try .init(from: post.creator)
        self.community = try .init(from: post.community)
        
        if let counts = post.counts {
            self.votes = .init(from: counts, myVote: .guaranteedInit(from: post.myVote))
        } else if let upvotes = post.post.upvotes, let downvotes = post.post.downvotes {
            self.votes = .init(upvotes: upvotes, downvotes: downvotes, myVote: .guaranteedInit(from: post.postActions?.likeScore))
        } else {
            throw .responseMissingRequiredData("LemmyPostView scores")
        }
        
        self.creatorIsModerator = post.creatorIsModerator
        self.creatorBannedFromCommunity = post.creatorBannedFromCommunity
        guard let creatorBlocked = post.creatorBlocked else {
            throw .responseMissingRequiredData("LemmyPostView creatorBlocked")
        }
        self.creatorBlocked = creatorBlocked
        
        self.creatorIsAdmin = post.creatorIsAdmin

        if let actions = post.postActions, let comments = post.post.comments {
            self.commentCount = comments
            self.unreadCommentCount = comments - (actions.readCommentsAmount ?? 0)
        } else if let counts = post.counts, let unreadComments = post.unreadComments {
            self.commentCount = counts.comments
            self.unreadCommentCount = unreadComments
        } else {
            throw .responseMissingRequiredData("LemmyPostView commentCount")
        }

        if let actions = post.postActions {
            self.saved = actions.saved != nil
            self.read = actions.read != nil
            self.hidden = actions.hidden != nil
        } else if let saved = post.saved, let read = post.read, let hidden = post.hidden {
            self.saved = saved
            self.read = read
            self.hidden = hidden
        } else {
            throw .responseMissingRequiredData("LemmyPostView actions")
        }
    }
    
    init(from report: LemmyPostReportView) throws(ApiClientError) {
        self.post = try .init(from: report.post)
        self.creator = try .init(from: report.postCreator)
        self.community = try .init(from: report.community)
        
        if let counts = report.counts {
            self.votes = .init(from: counts, myVote: .guaranteedInit(from: report.myVote))
        } else if let upvotes = report.post.upvotes, let downvotes = report.post.downvotes {
            self.votes = .init(upvotes: upvotes, downvotes: downvotes, myVote: .guaranteedInit(from: report.postActions?.likeScore))
        } else {
            throw .responseMissingRequiredData("LemmyPostReportView scores")
        }
        
        // I reckon this value being removed in 1.0.0 is an oversight,
        // so am null coalescing to `false` for now.
        // https://github.com/LemmyNet/lemmy/pull/5808#discussion_r2198777728
        self.creatorIsModerator = report.creatorIsModerator ?? false
        
        self.creatorBannedFromCommunity = report.creatorBannedFromCommunity ?? false
        guard let creatorBlocked = report.creatorBlocked else {
            throw .responseMissingRequiredData("LemmyPostReportView creatorBlocked")
        }
        self.creatorBlocked = creatorBlocked
        
        if let creatorIsAdmin = report.creatorIsAdmin {
            self.creatorIsAdmin = creatorIsAdmin
        } else {
            throw .responseMissingRequiredData("LemmyPostReportView creatorIsAdmin")
        }

        if let actions = report.postActions, let comments = report.post.comments {
            self.commentCount = comments
            self.unreadCommentCount = comments - (actions.readCommentsAmount ?? 0)
        } else if let counts = report.counts, let unreadComments = report.unreadComments {
            self.commentCount = counts.comments
            self.unreadCommentCount = unreadComments
        } else {
            throw .responseMissingRequiredData("LemmyPostReportView commentCount")
        }

        if let actions = report.postActions {
            self.saved = actions.saved != nil
            self.read = actions.read != nil
            self.hidden = actions.hidden != nil
        } else if let saved = report.saved, let read = report.read, let hidden = report.hidden {
            self.saved = saved
            self.read = read
            self.hidden = hidden
        } else {
            throw .responseMissingRequiredData("LemmyPostReportView actions")
        }
    }
}

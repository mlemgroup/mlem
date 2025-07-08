//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-05-06.
//

import Foundation

public struct Post2Snapshot: CacheIdentifiable, PostSnapshotProviding {
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
    
    init(from post: ApiPostView) throws(ApiClientError) {
        self.post = try .init(from: post.post)
        self.creator = try .init(from: post.creator)
        self.community = try .init(from: post.community)
        
        if let counts = post.counts {
            self.votes = .init(from: counts, myVote: .guaranteedInit(from: post.myVote))
        } else if let upvotes = post.post.upvotes, let downvotes = post.post.downvotes {
            self.votes = .init(upvotes: upvotes, downvotes: downvotes, myVote: .guaranteedInit(from: post.postActions?.likeScore))
        } else {
            throw .responseMissingRequiredData("ApiPostView scores")
        }
        
        if let actions = post.creatorCommunityActions {
            self.creatorIsModerator = actions.becameModerator != nil
            self.creatorBannedFromCommunity = actions.banExpires != nil
            self.creatorBlocked = actions.blocked != nil
        } else {
            self.creatorIsModerator = post.creatorIsModerator
            self.creatorBannedFromCommunity = post.creatorBannedFromCommunity ?? false
            guard let creatorBlocked = post.creatorBlocked else {
                throw .responseMissingRequiredData("ApiPostView creatorBlocked")
            }
            self.creatorBlocked = creatorBlocked
        }
        
        self.creatorIsAdmin = post.creatorIsAdmin

        if let actions = post.postActions, let comments = post.post.comments {
            self.commentCount = comments
            self.unreadCommentCount = comments - (actions.readCommentsAmount ?? 0)
        } else if let counts = post.counts, let unreadComments = post.unreadComments {
            self.commentCount = counts.comments
            self.unreadCommentCount = unreadComments
        } else {
            throw .responseMissingRequiredData("ApiPostView commentCount")
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
            throw .responseMissingRequiredData("ApiPostView actions")
        }
    }
    
    init(from report: ApiPostReportView) throws(ApiClientError) {
        self.post = try .init(from: report.post)
        self.creator = try .init(from: report.postCreator)
        self.community = try .init(from: report.community)
        
        if let counts = report.counts {
            self.votes = .init(from: counts, myVote: .guaranteedInit(from: report.myVote))
        } else if let upvotes = report.post.upvotes, let downvotes = report.post.downvotes {
            self.votes = .init(upvotes: upvotes, downvotes: downvotes, myVote: .guaranteedInit(from: report.postActions?.likeScore))
        } else {
            throw .responseMissingRequiredData("ApiPostReportView scores")
        }
        
        if let actions = report.creatorCommunityActions {
            self.creatorIsModerator = actions.becameModerator != nil
            self.creatorBannedFromCommunity = actions.banExpires != nil
            self.creatorBlocked = actions.blocked != nil
        } else {
            self.creatorIsModerator = report.creatorIsModerator
            self.creatorBannedFromCommunity = report.creatorBannedFromCommunity ?? false
            guard let creatorBlocked = report.creatorBlocked else {
                throw .responseMissingRequiredData("ApiPostReportView creatorBlocked")
            }
            self.creatorBlocked = creatorBlocked
        }
        
        if let creatorIsAdmin = report.creatorIsAdmin {
            self.creatorIsAdmin = creatorIsAdmin
        } else {
            throw .responseMissingRequiredData("ApiPostReportView creatorIsAdmin")
        }

        if let actions = report.postActions, let comments = report.post.comments {
            self.commentCount = comments
            self.unreadCommentCount = comments - (actions.readCommentsAmount ?? 0)
        } else if let counts = report.counts, let unreadComments = report.unreadComments {
            self.commentCount = counts.comments
            self.unreadCommentCount = unreadComments
        } else {
            throw .responseMissingRequiredData("ApiPostReportView commentCount")
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
            throw .responseMissingRequiredData("ApiPostReportView actions")
        }
    }
}

//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-19.
//

import Foundation

public extension Post2Snapshot {
    init(from post: PieFedPostView) throws(ApiClientError) {
        self.post = try .init(from: post.post)
        self.creator = try .init(from: post.creator)
        self.community = try .init(from: post.community)
        
        self.votes = .init(
            upvotes: post.counts.upvotes,
            downvotes: post.counts.downvotes,
            myVote: .guaranteedInit(from: post.myVote)
        )
        self.saved = post.saved
        self.read = post.read
        self.hidden = post.hidden
        
        self.commentCount = post.counts.comments
        self.unreadCommentCount = 0
        self.creatorIsModerator = post.creatorIsModerator
        self.creatorIsAdmin = post.creatorIsAdmin
        self.creatorBannedFromCommunity = post.creatorBannedFromCommunity
        self.creatorBlocked = false
    }
    
    init(from report: PieFedPostReportView) throws(ApiClientError) {
        self.post = try .init(from: report.post)
        self.creator = try .init(from: report.postCreator)
        self.community = try .init(from: report.community)
        
        self.votes = .init(from: report.counts, myVote: .guaranteedInit(from: report.myVote))
        
        self.creatorIsModerator = report.creatorIsModerator
        
        self.creatorBannedFromCommunity = report.creatorBannedFromCommunity
        self.creatorBlocked = report.creatorBlocked
        self.creatorIsAdmin = report.creatorIsAdmin

        self.commentCount = report.counts.comments
        self.unreadCommentCount = 0
        
        self.saved = report.saved
        self.read = false
        self.hidden = false
    }
}

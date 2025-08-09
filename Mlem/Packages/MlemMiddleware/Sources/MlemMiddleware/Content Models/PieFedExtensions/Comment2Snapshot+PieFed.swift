//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-19.
//

import Foundation

public extension Comment2Snapshot {
    init(from comment: PieFedCommentView) throws(ApiClientError) {
        self.comment = try .init(from: comment.comment)
        self.creator = try .init(from: comment.creator)
        self.post = try .init(from: comment.post)
        self.community = try .init(from: comment.community)
        
        self.commentCount = comment.counts.childCount
        self.creatorIsModerator = comment.creatorIsModerator
        self.creatorIsAdmin = comment.creatorIsAdmin
        self.creatorBannedFromCommunity = comment.creatorBannedFromCommunity
        
        self.votes = .init(
            upvotes: comment.counts.upvotes,
            downvotes: comment.counts.downvotes,
            myVote: .guaranteedInit(from: comment.myVote)
        )
        self.saved = comment.saved
    }
    
    init(from report: PieFedCommentReportView) throws(ApiClientError) {
        self.comment = try .init(from: report.comment)
        self.creator = try .init(from: report.commentCreator)
        self.post = try .init(from: report.post)
        self.community = try .init(from: report.community)
        
        self.commentCount = report.counts.childCount
        self.creatorIsAdmin = report.creatorIsAdmin
        self.creatorIsModerator = report.creatorIsModerator
        self.creatorBannedFromCommunity = report.creatorBannedFromCommunity
        self.saved = report.saved
        
        self.votes = .init(from: report.counts, myVote: .guaranteedInit(from: report.myVote))
    }
}

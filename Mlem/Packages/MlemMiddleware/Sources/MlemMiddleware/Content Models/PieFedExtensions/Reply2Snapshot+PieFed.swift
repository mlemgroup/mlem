//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-25.
//

import Foundation

public extension Reply2Snapshot {
    init(from commentReply: PieFedCommentReplyView) throws(ApiClientError) {
        self.reply = try .init(from: commentReply.commentReply)
        self.comment = try .init(from: commentReply.comment)
        self.creator = try .init(from: commentReply.creator)
        self.post = try .init(from: commentReply.post)
        self.community = try .init(from: commentReply.community)
        self.recipient = try .init(from: commentReply.recipient)
        
        self.subscribed = commentReply.subscribed.isSubscribed
        self.commentCount = commentReply.counts.childCount
        self.creatorIsAdmin = commentReply.creatorIsAdmin
        self.creatorIsModerator = commentReply.creatorIsModerator
        self.creatorBannedFromCommunity = commentReply.creatorBannedFromCommunity
        self.saved = commentReply.saved
        self.votes = .init(
            upvotes: commentReply.counts.upvotes,
            downvotes: commentReply.counts.downvotes,
            myVote: .guaranteedInit(from: commentReply.myVote)
        )
    }
}

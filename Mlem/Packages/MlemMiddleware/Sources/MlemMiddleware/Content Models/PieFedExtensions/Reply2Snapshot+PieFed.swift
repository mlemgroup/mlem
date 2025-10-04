//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-25.
//

import Foundation

public extension Reply2Snapshot {
    init(from commentReply: PieFedCommentReplyView, isMention: Bool) throws(ApiClientError) {
        let votes = VotesModel(
            upvotes: commentReply.counts.upvotes,
            downvotes: commentReply.counts.downvotes,
            myVote: .guaranteedInit(from: commentReply.myVote)
        )

        try self.init(
            reply: .init(from: commentReply.commentReply, isMention: isMention),
            comment: .init(from: commentReply.comment),
            creator: .init(from: commentReply.creator),
            post: .init(from: commentReply.post),
            community: .init(from: commentReply.community),
            recipient: .init(from: commentReply.recipient),
            subscribed: commentReply.subscribed.isSubscribed,
            commentCount: commentReply.counts.childCount,
            creatorIsModerator: commentReply.creatorIsModerator,
            creatorIsAdmin: commentReply.creatorIsAdmin,
            creatorBannedFromCommunity: commentReply.creatorBannedFromCommunity,
            votes: votes,
            saved: commentReply.saved
        )
    }
}

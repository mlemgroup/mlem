//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-07-14.
//

import Foundation

extension Reply2Snapshot {
    init(from commentReply: LemmyCommentReplyView) throws(ApiClientError) {
        try self.init(
            reply: .init(from: commentReply.commentReply),
            comment: .init(from: commentReply.comment),
            creator: .init(from: commentReply.creator),
            post: .init(from: commentReply.post),
            community: .init(from: commentReply.community),
            recipient: .init(from: commentReply.recipient),
            subscribed: commentReply.subscribed != .notSubscribed,
            commentCount: commentReply.counts.childCount,
            creatorIsModerator: commentReply.creatorIsModerator,
            creatorIsAdmin: commentReply.creatorIsAdmin,
            creatorBannedFromCommunity: commentReply.creatorBannedFromCommunity,
            votes: .init(from: commentReply.counts, myVote: .guaranteedInit(from: commentReply.myVote)),
            saved: commentReply.saved
        )
    }
    
    init(from personMention: LemmyPersonCommentMentionView) throws(ApiClientError) {
        try self.init(
            reply: .init(from: personMention.personMention),
            comment: .init(from: personMention.comment),
            creator: .init(from: personMention.creator),
            post: .init(from: personMention.post),
            community: .init(from: personMention.community),
            recipient: .init(from: personMention.recipient),
            subscribed: personMention.subscribed != .notSubscribed,
            commentCount: personMention.counts.childCount,
            creatorIsModerator: personMention.creatorIsModerator,
            creatorIsAdmin: personMention.creatorIsAdmin,
            creatorBannedFromCommunity: personMention.creatorBannedFromCommunity,
            votes: .init(from: personMention.counts, myVote: .guaranteedInit(from: personMention.myVote)),
            saved: personMention.saved
        )
    }
}

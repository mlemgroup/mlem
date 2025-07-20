//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-07-14.
//

import Foundation

extension Reply2Snapshot {
    init(from commentReply: LemmyCommentReplyView) throws(ApiClientError) {
        self.reply = try .init(from: commentReply.commentReply)
        self.comment = try .init(from: commentReply.comment)
        self.creator = try .init(from: commentReply.creator)
        self.post = try .init(from: commentReply.post)
        self.community = try .init(from: commentReply.community)
        self.recipient = try .init(from: commentReply.recipient)
        self.subscribed = commentReply.subscribed != .notSubscribed
        self.commentCount = commentReply.counts.childCount
        self.creatorIsAdmin = commentReply.creatorIsAdmin
        self.creatorIsModerator = commentReply.creatorIsModerator
        self.creatorBannedFromCommunity = commentReply.creatorBannedFromCommunity
        self.saved = commentReply.saved
        self.votes = .init(from: commentReply.counts, myVote: .guaranteedInit(from: commentReply.myVote))
    }
    
    init(from personMention: LemmyPersonCommentMentionView) throws(ApiClientError) {
        self.reply = try .init(from: personMention.personMention)
        self.comment = try .init(from: personMention.comment)
        self.creator = try .init(from: personMention.creator)
        self.post = try .init(from: personMention.post)
        self.community = try .init(from: personMention.community)
        self.recipient = try .init(from: personMention.recipient)
        self.subscribed = personMention.subscribed != .notSubscribed
        self.commentCount = personMention.counts.childCount
        self.creatorIsAdmin = personMention.creatorIsAdmin
        self.creatorIsModerator = personMention.creatorIsModerator
        self.creatorBannedFromCommunity = personMention.creatorBannedFromCommunity
        self.saved = personMention.saved
        self.votes = .init(from: personMention.counts, myVote: .guaranteedInit(from: personMention.myVote))
    }
}

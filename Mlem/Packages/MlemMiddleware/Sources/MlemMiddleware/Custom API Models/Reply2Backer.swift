//
//  Reply2ApiBacker.swift
//
//
//  Created by Sjmarf on 05/07/2024.
//

import Foundation

public struct Reply2Backer: CacheIdentifiable {
    public let reply: Reply1Backer
    public let comment: ApiComment
    public let creator: ApiPerson
    public let post: ApiPost
    public let community: ApiCommunity
    public let recipient: ApiPerson
    public let creatorBannedFromCommunity: Bool
    public let subscribed: ApiSubscribedType
    public let creatorBlocked: Bool
    public let myVote: Int?
    /// Added in 0.19.0
    public let creatorIsModerator: Bool?
    /// Added in 0.19.0
    public let creatorIsAdmin: Bool?
    /// Added in 0.19.4
    public let bannedFromCommunity: Bool?
    public let counts: ApiCommentAggregates
    public let saved: Bool
    
    public var cacheId: Int { reply.id }
    
    init(from commentReply: ApiCommentReplyView) {
        self.reply = .init(from: commentReply.reply)
        self.comment = commentReply.comment
        self.creator = commentReply.creator
        self.post = commentReply.post
        self.community = commentReply.community
        self.recipient = commentReply.recipient
        self.creatorBannedFromCommunity = commentReply.creatorBannedFromCommunity ?? false
        self.subscribed = commentReply.subscribed ?? .notSubscribed
        self.creatorBlocked = commentReply.creatorBlocked ?? false
        self.myVote = commentReply.myVote
        self.creatorIsModerator = commentReply.creatorIsModerator
        self.creatorIsAdmin = commentReply.creatorIsAdmin
        self.bannedFromCommunity = commentReply.bannedFromCommunity
        self.counts = commentReply.counts ?? .zero
        self.saved = commentReply.saved ?? false
    }
    
    init(from personMention: ApiPersonMentionView) {
        self.reply = .init(from: personMention.personMention)
        self.comment = personMention.comment
        self.creator = personMention.creator
        self.post = personMention.post
        self.community = personMention.community
        self.recipient = personMention.recipient
        self.creatorBannedFromCommunity = personMention.creatorBannedFromCommunity
        self.subscribed = personMention.subscribed
        self.creatorBlocked = personMention.creatorBlocked
        self.myVote = personMention.myVote
        self.creatorIsModerator = personMention.creatorIsModerator
        self.creatorIsAdmin = personMention.creatorIsAdmin
        self.bannedFromCommunity = personMention.bannedFromCommunity
        self.counts = personMention.counts
        self.saved = personMention.saved
    }
}

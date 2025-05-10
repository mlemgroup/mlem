//
//  Reply2ApiBacker.swift
//
//
//  Created by Sjmarf on 05/07/2024.
//

import Foundation

public struct Reply2Snapshot: CacheIdentifiable {
    // Won't change, but the corresponding models need to
    // be updated within the `update` method of Reply2.
    public let reply: Reply1Snapshot
    public let comment: Comment1Snapshot
    public let creator: Person1Snapshot
    public let post: Post1Snapshot
    public let community: Community1Snapshot
    public let recipient: Person1Snapshot
    
    // May change. If you add/remove items from this list,
    // remember to also amend the `update` method of Reply2!
    public let subscribed: Bool
    public let commentCount: Int
    public let creatorIsModerator: Bool?
    public let creatorIsAdmin: Bool?
    public let creatorBannedFromCommunity: Bool
    public let votes: VotesModel
    public let saved: Bool
    
    public var cacheId: Int { reply.id }
    
    init(from commentReply: ApiCommentReplyView) throws(ApiClientError) {
        self.reply = try .init(from: commentReply.commentReply)
        self.comment = try .init(from: commentReply.comment)
        self.creator = try .init(from: commentReply.creator)
        self.post = try .init(from: commentReply.post)
        self.community = try .init(from: commentReply.community)
        self.recipient = try .init(from: commentReply.recipient)
        
        if let communityActions = commentReply.communityActions {
            self.subscribed = communityActions.followState != nil
        } else if let subscribedType = commentReply.subscribed {
            self.subscribed = subscribedType != .notSubscribed
        } else {
            throw .responseMissingRequiredData
        }
        
        if let childCount = commentReply.comment.childCount ?? commentReply.counts?.childCount {
            self.commentCount = childCount
        } else {
            throw .responseMissingRequiredData
        }
        
        self.creatorIsAdmin = commentReply.creatorIsAdmin

        if let actions = commentReply.creatorCommunityActions {
            self.creatorIsModerator = actions.becameModerator != nil
            self.creatorBannedFromCommunity = actions.banExpires != nil
        } else {
            self.creatorIsModerator = commentReply.creatorIsModerator
            self.creatorBannedFromCommunity = commentReply.creatorBannedFromCommunity ?? false
            guard let creatorBlocked = commentReply.creatorBlocked else { throw .responseMissingRequiredData }
        }
        
        if let actions = commentReply.commentActions {
            self.saved = actions.saved != nil
        } else if let saved = commentReply.saved {
            self.saved = saved
        } else {
            throw .responseMissingRequiredData
        }
        
        if let counts = commentReply.counts, let myVote = commentReply.myVote {
            self.votes = .init(from: counts, myVote: .guaranteedInit(from: myVote))
        } else if let upvotes = commentReply.comment.upvotes, let downvotes = commentReply.comment.downvotes {
            self.votes = .init(upvotes: upvotes, downvotes: downvotes, myVote: .guaranteedInit(from: commentReply.commentActions?.likeScore))
        } else {
            throw .responseMissingRequiredData
        }
    }
    
    init(from personMention: ApiPersonCommentMentionView) throws(ApiClientError) {
        if let mention = personMention.personCommentMention ?? personMention.personMention {
            self.reply = try .init(from: mention)
        } else {
            throw .responseMissingRequiredData
        }
        
        self.comment = try .init(from: personMention.comment)
        self.creator = try .init(from: personMention.creator)
        self.post = try .init(from: personMention.post)
        self.community = try .init(from: personMention.community)
        self.recipient = try .init(from: personMention.recipient)
        
        if let communityActions = personMention.communityActions {
            self.subscribed = communityActions.followState != nil
        } else if let subscribedType = personMention.subscribed {
            self.subscribed = subscribedType != .notSubscribed
        } else {
            throw .responseMissingRequiredData
        }
        
        if let childCount = personMention.comment.childCount ?? personMention.counts?.childCount {
            self.commentCount = childCount
        } else {
            throw .responseMissingRequiredData
        }
        
        self.creatorIsAdmin = personMention.creatorIsAdmin

        if let actions = personMention.creatorCommunityActions {
            self.creatorIsModerator = actions.becameModerator != nil
            self.creatorBannedFromCommunity = actions.banExpires != nil
        } else {
            self.creatorIsModerator = personMention.creatorIsModerator
            self.creatorBannedFromCommunity = personMention.creatorBannedFromCommunity ?? false
            guard let creatorBlocked = personMention.creatorBlocked else { throw .responseMissingRequiredData }
        }
        
        if let actions = personMention.commentActions {
            self.saved = actions.saved != nil
        } else if let saved = personMention.saved {
            self.saved = saved
        } else {
            throw .responseMissingRequiredData
        }
        
        if let counts = personMention.counts, let myVote = personMention.myVote {
            self.votes = .init(from: counts, myVote: .guaranteedInit(from: myVote))
        } else if let upvotes = personMention.comment.upvotes, let downvotes = personMention.comment.downvotes {
            self.votes = .init(upvotes: upvotes, downvotes: downvotes, myVote: .guaranteedInit(from: personMention.commentActions?.likeScore))
        } else {
            throw .responseMissingRequiredData
        }
        
        // TODO: Cache init & `update`
    }
}

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
        
        if let communityActions = commentReply.communityActions {
            self.subscribed = communityActions.followState != nil
        } else if let subscribedType = commentReply.subscribed {
            self.subscribed = subscribedType != .notSubscribed
        } else {
            throw .responseMissingRequiredData("LemmyCommentReplyView subscribed")
        }
        
        if let childCount = commentReply.comment.childCount ?? commentReply.counts?.childCount {
            self.commentCount = childCount
        } else {
            throw .responseMissingRequiredData("LemmyCommentReplyView childCount")
        }
        
        self.creatorIsAdmin = commentReply.creatorIsAdmin

        self.creatorIsModerator = commentReply.creatorIsModerator
        self.creatorBannedFromCommunity = commentReply.creatorBannedFromCommunity
        
        if let actions = commentReply.commentActions {
            self.saved = actions.savedAt != nil
        } else if let saved = commentReply.saved {
            self.saved = saved
        } else {
            throw .responseMissingRequiredData("LemmyCommentReplyView saved")
        }
        
        if let counts = commentReply.counts {
            self.votes = .init(from: counts, myVote: .guaranteedInit(from: commentReply.myVote))
        } else if let upvotes = commentReply.comment.upvotes, let downvotes = commentReply.comment.downvotes {
            self.votes = .init(upvotes: upvotes, downvotes: downvotes, myVote: .guaranteedInit(from: commentReply.commentActions?.likeScore))
        } else {
            throw .responseMissingRequiredData("LemmyCommentReplyView score")
        }
    }
    
    init(from personMention: LemmyPersonCommentMentionView) throws(ApiClientError) {
        if let mention = personMention.personCommentMention ?? personMention.personMention {
            self.reply = try .init(from: mention)
        } else {
            throw .responseMissingRequiredData("LemmyPersonCommentMentionView mention")
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
            throw .responseMissingRequiredData("LemmyPersonCommentMentionView suscribed")
        }
        
        if let childCount = personMention.comment.childCount ?? personMention.counts?.childCount {
            self.commentCount = childCount
        } else {
            throw .responseMissingRequiredData("LemmyPersonCommentMentionView childCount")
        }
        
        self.creatorIsAdmin = personMention.creatorIsAdmin

        self.creatorIsModerator = personMention.creatorIsModerator
        self.creatorBannedFromCommunity = personMention.creatorBannedFromCommunity
        
        if let actions = personMention.commentActions {
            self.saved = actions.savedAt != nil
        } else if let saved = personMention.saved {
            self.saved = saved
        } else {
            throw .responseMissingRequiredData("LemmyPersonCommentMentionView saved")
        }
        
        if let counts = personMention.counts {
            self.votes = .init(from: counts, myVote: .guaranteedInit(from: personMention.myVote))
        } else if let upvotes = personMention.comment.upvotes, let downvotes = personMention.comment.downvotes {
            self.votes = .init(upvotes: upvotes, downvotes: downvotes, myVote: .guaranteedInit(from: personMention.commentActions?.likeScore))
        } else {
            throw .responseMissingRequiredData("LemmyPersonCommentMentionView score")
        }
    }
}

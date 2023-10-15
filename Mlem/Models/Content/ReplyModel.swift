//
//  ReplyModel.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-09-23.
//
import Foundation

/// Internal representation of a comment reply
struct ReplyModel {
    let commentReply: APICommentReply
    let comment: APIComment
    let creator: APIPerson
    let post: APIPost
    let community: APICommunity
    let recipient: APIPerson
    let counts: APICommentAggregates
    let creatorBannedFromCommunity: Bool
    let subscribed: APISubscribedStatus
    let saved: Bool
    let creatorBlocked: Bool
    let myVote: ScoringOperation?

    var uid: ContentModelIdentifier { .init(contentType: .reply, contentId: commentReply.id) }
    
    init(from replyView: APICommentReplyView) {
        self.commentReply = replyView.commentReply
        self.comment = replyView.comment
        self.creator = replyView.creator
        self.post = replyView.post
        self.community = replyView.community
        self.recipient = replyView.recipient
        self.counts = replyView.counts
        self.creatorBannedFromCommunity = replyView.creatorBannedFromCommunity
        self.subscribed = replyView.subscribed
        self.saved = replyView.saved
        self.creatorBlocked = replyView.creatorBlocked
        self.myVote = replyView.myVote
    }

    // TODO: hasher
    // TODO: published should be top-level based on commentReply.published
}

extension ReplyModel: Hashable {
    /// Hashes all fields for which state changes should trigger view updates.
    func hash(into hasher: inout Hasher) {
        hasher.combine(uid)
        hasher.combine(commentReply.read)
        hasher.combine(comment.updated)
        hasher.combine(counts.upvotes)
        hasher.combine(counts.downvotes)
        hasher.combine(myVote)
        hasher.combine(saved)
    }
}

extension ReplyModel: Identifiable {
    var id: Int { hashValue }
}

extension ReplyModel: Equatable {
    static func == (lhs: ReplyModel, rhs: ReplyModel) -> Bool {
        lhs.id == rhs.id
    }
}

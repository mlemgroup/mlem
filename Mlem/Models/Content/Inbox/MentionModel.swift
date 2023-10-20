//
//  MentionModel.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-09-23.
//
import Foundation

/// Internal representation of a person mention
struct MentionModel {
    let personMention: APIPersonMention
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

    var uid: ContentModelIdentifier { .init(contentType: .mention, contentId: personMention.id) }
    
    init(from personMentionView: APIPersonMentionView) {
        self.personMention = personMentionView.personMention
        self.comment = personMentionView.comment
        self.creator = personMentionView.creator
        self.post = personMentionView.post
        self.community = personMentionView.community
        self.recipient = personMentionView.recipient
        self.counts = personMentionView.counts
        self.creatorBannedFromCommunity = personMentionView.creatorBannedFromCommunity
        self.subscribed = personMentionView.subscribed
        self.saved = personMentionView.saved
        self.creatorBlocked = personMentionView.creatorBlocked
        self.myVote = personMentionView.myVote
    }
}

extension MentionModel: Hashable {
    /// Hashes all fields for which state changes should trigger view updates.
    func hash(into hasher: inout Hasher) {
        hasher.combine(uid)
        hasher.combine(personMention.read)
        hasher.combine(comment.updated)
        hasher.combine(comment.deleted)
        hasher.combine(counts.upvotes)
        hasher.combine(counts.downvotes)
        hasher.combine(myVote)
        hasher.combine(saved)
    }
}

extension MentionModel: Identifiable {
    var id: Int { hashValue }
}

extension MentionModel: Equatable {
    static func == (lhs: MentionModel, rhs: MentionModel) -> Bool {
        lhs.id == rhs.id
    }
}

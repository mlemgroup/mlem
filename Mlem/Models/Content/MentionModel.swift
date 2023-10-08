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

    func getInboxSortVal(sortType: InboxSortType) -> InboxSortVal {
        switch sortType {
        case .published:
            return .published(personMention.published)
        }
    }

    // TODO: hasher
    // TODO: published should be top-level based on personMention.published
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

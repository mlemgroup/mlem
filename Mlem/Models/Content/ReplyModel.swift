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
    
    func getInboxSortVal(sortType: InboxSortType) -> InboxSortVal {
        switch sortType {
        case .published:
            return .published(commentReply.published)
        }
    }
    
    // TODO: hasher
    // TODO: published should be top-level based on commentReply.published
}

//
//  APICommentReplyView.swift
//  Mlem
//
//  Created by Jonathan de Jong on 14.06.2023.
//

import Foundation

// lemmy_db_views::structs::CommentReplyView
struct APICommentReplyView: Decodable {
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
    let myVote: Int?
}

extension APICommentReplyView: Identifiable {
    var id: Int { commentReply.id }
}

// MARK: - FeedTrackerItem

extension APICommentReplyView: FeedTrackerItem {
    var uniqueIdentifier: some Hashable { id }
    var published: Date { commentReply.published }
}

//
//  APICommentReplyView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/CommentReplyView.ts
struct APICommentReplyView: Codable {
    let comment_reply: APICommentReply
    let comment: APIComment
    let creator: APIPerson
    let post: APIPost
    let community: APICommunity
    let recipient: APIPerson
    let counts: APICommentAggregates
    let creator_banned_from_community: Bool
    let creator_is_moderator: Bool
    let creator_is_admin: Bool
    let subscribed: APISubscribedType
    let saved: Bool
    let creator_blocked: Bool
    let my_vote: Int?

    func toQueryItems() -> [URLQueryItem] {
        [
        ]
    }
}

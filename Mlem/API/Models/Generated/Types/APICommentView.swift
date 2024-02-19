//
//  APICommentView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// sources/js/types/CommentView.ts
struct APICommentView: Codable {
    let comment: APIComment
    let creator: APIPerson
    let post: APIPost
    let community: APICommunity
    let counts: APICommentAggregates
    let creator_banned_from_community: Bool
    let creator_is_moderator: Bool
    let creator_is_admin: Bool
    let subscribed: APISubscribedType
    let saved: Bool
    let creator_blocked: Bool
    let my_vote: Int?
}

//
//  APIPostView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/PostView.ts
struct APIPostView: Codable {
    let post: APIPost
    let creator: APIPerson
    let community: APICommunity
    let creator_banned_from_community: Bool
    let creator_is_moderator: Bool
    let creator_is_admin: Bool
    let counts: APIPostAggregates
    let subscribed: APISubscribedType
    let saved: Bool
    let read: Bool
    let creator_blocked: Bool
    let my_vote: Int?
    let unread_comments: Int

    func toQueryItems() -> [URLQueryItem] {
        [
        ]
    }
}

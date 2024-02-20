//
//  APIPostView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-20
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// PostView.ts
struct APIPostView: Codable {
    let post: APIPost
    let creator: APIPerson
    let community: APICommunity
    let creatorBannedFromCommunity: Bool
    let creatorIsModerator: Bool?
    let creatorIsAdmin: Bool?
    let counts: APIPostAggregates
    let subscribed: APISubscribedType
    let saved: Bool
    let read: Bool
    let creatorBlocked: Bool
    let myVote: Int?
    let unreadComments: Int
}

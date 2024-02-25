//
//  ApiPostView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-25
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// PostView.ts
struct ApiPostView: Codable {
    let post: ApiPost
    let creator: ApiPerson
    let community: ApiCommunity
    let creatorBannedFromCommunity: Bool
    let counts: ApiPostAggregates
    let subscribed: ApiSubscribedType
    let saved: Bool
    let read: Bool
    let creatorBlocked: Bool
    let myVote: Int?
    let unreadComments: Int
    let creatorIsModerator: Bool?
    let creatorIsAdmin: Bool?
}

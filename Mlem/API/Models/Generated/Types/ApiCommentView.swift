//
//  ApiCommentView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// CommentView.ts
struct ApiCommentView: Codable {
    let comment: ApiComment
    let creator: ApiPerson
    let post: ApiPost
    let community: ApiCommunity
    let counts: ApiCommentAggregates
    let creatorBannedFromCommunity: Bool
    let creatorIsModerator: Bool?
    let creatorIsAdmin: Bool?
    let subscribed: ApiSubscribedType
    let saved: Bool
    let creatorBlocked: Bool
    let myVote: Int?
}

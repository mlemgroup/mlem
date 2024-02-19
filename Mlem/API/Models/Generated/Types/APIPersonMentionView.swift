//
//  APIPersonMentionView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// ../sources/js/types/PersonMentionView.ts
struct APIPersonMentionView: Codable {
    let personMention: APIPersonMention
    let comment: APIComment
    let creator: APIPerson
    let post: APIPost
    let community: APICommunity
    let recipient: APIPerson
    let counts: APICommentAggregates
    let creatorBannedFromCommunity: Bool
    let creatorIsModerator: Bool
    let creatorIsAdmin: Bool
    let subscribed: APISubscribedType
    let saved: Bool
    let creatorBlocked: Bool
    let myVote: Int?
}

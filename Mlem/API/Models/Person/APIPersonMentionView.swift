//
//  APIPersonMention.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-26.
//

import Foundation
import SwiftUI

// lemmy_db_views_actor::structs::PersonMentionView
struct APIPersonMentionView: Decodable {
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
}

extension APIPersonMentionView: Identifiable {
    var id: Int { personMention.id }
}

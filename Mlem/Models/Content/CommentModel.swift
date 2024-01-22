//
//  CommentModel.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-01-22.
//

import Foundation

class CommentModel: ContentIdentifiable, ObservableObject {
    let comment: APIComment
    let creator: APIPerson
    let post: APIPost
    let community: APICommunity
    let counts: APICommentAggregates
    let creatorBannedFromCommunity: Bool
    let creatorIsModerator: Bool? // TODO: 0.18 deprecation make this field non-optional
    let creatorIsAdmin: Bool? // TODO: 0.18 deprecation make this field non-optional
    let subscribed: APISubscribedStatus
    let saved: Bool
    let creatorBlocked: Bool
    var myVote: ScoringOperation?
    
    init(from apiCommentView: APICommentView) {}
}

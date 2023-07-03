//
//  APICommentReportView.swift
//  Mlem
//
//  Created by Jake Shirley on 7/2/23.
//

import Foundation

// lemmy_db_views::structs::CommentReportView
struct APICommentReportView: Decodable {
    let commentReport: APICommentReport
    let comment: APIComment
    let post: APIPost
    let community: APICommunity
    let creator: APIPerson
    let commentCreator: APIPerson
    let counts: APICommentAggregates
    let creatorBannedFromCommunity: Bool
    let myVote: Int?
    let resolver: APIPerson?
}

//
//  APICommentReportView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// sources/js/types/CommentReportView.ts
struct APICommentReportView: Codable {
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

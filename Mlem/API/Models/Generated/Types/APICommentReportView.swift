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
    let comment_report: APICommentReport
    let comment: APIComment
    let post: APIPost
    let community: APICommunity
    let creator: APIPerson
    let comment_creator: APIPerson
    let counts: APICommentAggregates
    let creator_banned_from_community: Bool
    let my_vote: Int?
    let resolver: APIPerson?
}

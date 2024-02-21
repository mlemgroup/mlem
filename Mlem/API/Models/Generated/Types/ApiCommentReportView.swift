//
//  ApiCommentReportView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// CommentReportView.ts
struct ApiCommentReportView: Codable {
    let commentReport: ApiCommentReport
    let comment: ApiComment
    let post: ApiPost
    let community: ApiCommunity
    let creator: ApiPerson
    let commentCreator: ApiPerson
    let counts: ApiCommentAggregates
    let creatorBannedFromCommunity: Bool
    let myVote: Int?
    let resolver: ApiPerson?
}

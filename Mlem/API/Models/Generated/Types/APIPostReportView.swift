//
//  APIPostReportView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// sources/js/types/PostReportView.ts
struct APIPostReportView: Codable {
    let postReport: APIPostReport
    let post: APIPost
    let community: APICommunity
    let creator: APIPerson
    let postCreator: APIPerson
    let creatorBannedFromCommunity: Bool
    let myVote: Int?
    let counts: APIPostAggregates
    let resolver: APIPerson?
}

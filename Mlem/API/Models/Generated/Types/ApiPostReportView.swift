//
//  ApiPostReportView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21
//

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

import Foundation

// PostReportView.ts
struct ApiPostReportView: Codable {
    let postReport: ApiPostReport
    let post: ApiPost
    let community: ApiCommunity
    let creator: ApiPerson
    let postCreator: ApiPerson
    let creatorBannedFromCommunity: Bool
    let myVote: Int?
    let counts: ApiPostAggregates
    let resolver: ApiPerson?
}

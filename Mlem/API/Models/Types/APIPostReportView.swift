//
//  APIPostReportView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-18
//

import Foundation

// ---- AUTOMATICALLY GENERATED FILE, DO NOT MODIFY ---- //

// sources/js/types/PostReportView.ts
struct APIPostReportView: Codable {
    let post_report: APIPostReport
    let post: APIPost
    let community: APICommunity
    let creator: APIPerson
    let post_creator: APIPerson
    let creator_banned_from_community: Bool
    let my_vote: Int?
    let counts: APIPostAggregates
    let resolver: APIPerson?

    func toQueryItems() -> [URLQueryItem] {
        [
        ]
    }
}

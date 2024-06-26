//
//  APIPostReport.swift
//  Mlem
//
//  Created by Jake Shirley on 7/1/23.
//

import Foundation

// lemmy_db_schema::source::post::PostReport
struct APIPostReport: Hashable, Decodable {
    let id: Int
    let creatorId: Int
    let postId: Int
    let originalPostName: String
    let originalPostUrl: String?
    let originalPostBody: String?
    let reason: String
    var resolved: Bool
    let resolverId: Int?
    let published: Date
    let updated: Date?
}

extension APIPostReport {
    var originalUrl: URL? { LemmyURL(string: originalPostUrl)?.url }
}

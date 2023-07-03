//
//  APIPostReport.swift
//  Mlem
//
//  Created by Jake Shirley on 7/1/23.
//

import Foundation

// lemmy_db_schema::source::post::PostReport
struct APIPostReport: Decodable {
    let id: Int
    let creatorId: Int
    let postId: Int
    let originalPostName: String
    let originalPostUrl: URL?
    let originalPostBody: String?
    let reason: String
    let resolved: Bool
    let resolverId: Int?
    let published: Date
    let updated: Date?
}
